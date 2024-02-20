import 'package:flutter/material.dart';
import 'package:flutter_noticias/models/Response.dart';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:flutter_noticias/utils/secureStorage.dart';
import 'package:flutter_noticias/utils/toast.dart';

// ! pruena
import 'package:geolocator/geolocator.dart';

class NoticiaDetailPage extends StatefulWidget {
  // * Parametros
  final String externalNoticia;

  const NoticiaDetailPage({
    Key? key,
    required this.externalNoticia,
  }) : super(key: key);

  @override
  _NoticiaDetailPageState createState() => _NoticiaDetailPageState();
}

class _NoticiaDetailPageState extends State<NoticiaDetailPage> {
  Future<Response>? futureComentario;
  Response noticia = Response(msg: '', code: 100);
  String externalUser = '';
  dynamic comentarioExternal = 'xd';
  bool isEditing = false;
  int currentPage = 1;
  int totalPages = 1;
  Position? position;

  final TextEditingController cuerpoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    iniciarCargaDatos();
    getLocation();
  }

  void getLocation() async {
    // * Pide los permisos al usuario
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // El usuario no otorgó permisos de ubicación
        print('El usuario no otorgó permisos de ubicación');
      }
    }

    try {
      Position positionA = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      print('Posición: $positionA');

      position = positionA;
    } catch (e) {
      print('Error al obtener la posición: $e');
      Navigator.pop(context);
    }
  }

  void iniciarCargaDatos() async {
    externalUser = (await SecureStorage.read(
        'external_user'))!; //! Asegura que NUNCA se obtendra un null
  }

  void _guardar() {
    setState(() {
      if (cuerpoController.text.isEmpty) {
        ToastUtil.errorMessage('No se puede subir un comentario vacio');
      } else {
        Map<String, String> data = {
          "cuerpo": cuerpoController.text,
          "latitud": position?.latitude != null ? '${position!.latitude}' : '1.5',
          "longitud": position?.longitude != null ? '${position!.longitude}' : '1.7',
          // "latitud": '1.5',
          // "longitud": '1.7',
          "external_noticia": widget.externalNoticia,
          "external_persona": externalUser,
        };

        print(data);

        setState(() {
          if (isEditing == true) {
            // * Modificación de data
            data = {
              "cuerpo": cuerpoController.text,
              "external_id": comentarioExternal
            };

            print('dataa actu $data');

            // * Reseto de variables
            cuerpoController.text = '';
            isEditing = false;

            futureComentario = enviar('comentario/update', false, data);
          } else {
            futureComentario = enviar('comentario/save', false, data);
          }
        });

        futureComentario?.then((datos) {
          print('Datos del futureComentario: $datos');
          if (datos.code == 200) {
            ToastUtil.successfullMessage('Comentario registrado');
          } else {
            ToastUtil.errorMessage(datos.tag);
          }
        }).catchError((error) {
          print('Error al recibir los datos del futureComentario: $error');
          ToastUtil.errorMessage('No se pudo subir el comentario');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: obtener('noticia/obtener/${widget.externalNoticia}', false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.datos == null) {
          return const Text('No hay datos disponibles.');
        } else {
          noticia = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle de la Noticia'),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (noticia.datos['archivo'] != null)
                    Image.network(
                        'http://192.168.1.5:3000/multimedia/${noticia.datos['archivo']}'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noticia.datos['titulo'],
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          noticia.datos['cuerpo'],
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Fecha de Publicación: ${noticia.datos['fecha']}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        Text(
                          'Autor: ${noticia.datos['persona']['nombres']} ${noticia.datos['persona']['apellidos']}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Comentarios',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),

                        // Aquí utilizamos otro FutureBuilder para cargar los comentarios
                        FutureBuilder<Response>(
                          future: obtener(
                              'comentario/list/noticia/${widget.externalNoticia}?page=$currentPage',
                              false),
                          builder: (context, comentariosSnapshot) {
                            if (comentariosSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (comentariosSnapshot.hasError) {
                              return Text(
                                  'Error: ${comentariosSnapshot.error}');
                            } else if (!comentariosSnapshot.hasData ||
                                comentariosSnapshot.data!.datos == null) {
                              return const Text(
                                  'No hay comentarios disponibles.');
                            } else {
                              totalPages = comentariosSnapshot.data!.totalPages;
                              // * Lista de comentarios
                              List<Widget> listaComentarios =
                                  comentariosSnapshot.data!.datos
                                      .map<Widget>((comentario) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comentario['cuerpo'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // * El IF sin llaves
                                        if (externalUser ==
                                            comentario['persona']
                                                ['external_id'])
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isEditing = true;
                                                  // * Asignación del cuepro del comentario
                                                  cuerpoController.text =
                                                      comentario['cuerpo'];
                                                  comentarioExternal =
                                                      comentario['external_id'];
                                                });
                                              },
                                              child: const Icon(
                                                Icons.edit,
                                                size: 18,
                                              ), // Icono con forma de lápiz
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Fecha: ${comentario['fecha']}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      'Autor: ${comentario['persona']['nombres']} ${comentario['persona']['apellidos']}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const Divider(), //? Separador entre comentarios
                                  ],
                                );
                              }).toList();

                              // return Column(
                              //   children: listaComentarios,
                              // );
                              return Column(
                                children: [
                                  ...listaComentarios,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: currentPage > 1
                                            ? () {
                                                setState(() {
                                                  currentPage--;
                                                });
                                              }
                                            : null,
                                        icon: const Icon(Icons.arrow_back),
                                      ),
                                      Text(
                                          'Página $currentPage de $totalPages'),
                                      IconButton(
                                        onPressed: currentPage < totalPages
                                            ? () {
                                                setState(() {
                                                  currentPage++;
                                                });
                                              }
                                            : null,
                                        icon: const Icon(Icons.arrow_forward),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: cuerpoController,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu comentario...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _guardar,
                              child: isEditing == true
                                  ? const Text('Actualizar')
                                  : const Text('Enviar Comentario'),
                            ),
                            const SizedBox(width: 24.0),
                            if (isEditing == true)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = false;
                                    cuerpoController.text = '';
                                    comentarioExternal = '';
                                  });
                                },
                                child: const Text('Cancelar'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
