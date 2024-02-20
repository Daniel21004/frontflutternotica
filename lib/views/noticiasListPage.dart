import 'package:flutter/material.dart';
import 'package:flutter_noticias/models/Response.dart';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:flutter_noticias/utils/Constants.dart';
import 'package:flutter_noticias/utils/secureStorage.dart';
import 'package:flutter_noticias/utils/toast.dart';

class NoticiasListPage extends StatefulWidget {
  const NoticiasListPage({Key? key}) : super(key: key);

  @override
  _NoticiasListPageState createState() => _NoticiasListPageState();
}

class _NoticiasListPageState extends State<NoticiasListPage> {
  Future<Response>? futureNoticias;
  Future<Response>? futurePersona;
  String externalUser = '';
  String rol = '';
  // ! Caparazon para el response
  Response res = Response(msg: '', code: 100);

  String nombreCompletaPersona = 'Unkown';

  @override
  void initState() {
    super.initState();

    iniciarCargaDatos();
  }

  void iniciarCargaDatos() async {
    var noticiasFuture = obtener('noticia/listuser', false);
    // var externalUser = await SecureStorage.read('external_user');
    externalUser = (await SecureStorage.read(
        'external_user'))!; //! Asegura que NUNCA se obtendra un null

    rol = (await SecureStorage.read(
        'rol'))!; //! Asegura que NUNCA se obtendra un null
    print('ext $externalUser');
    print('rol $rol');
    var personaFuture = obtener('persona/obtener/$externalUser', false);

    setState(() {
      futureNoticias = noticiasFuture;
      futurePersona = personaFuture;
    });

    await futurePersona?.then((data) {
      print('Datos del futurePersona: $data');
      res = data;
      print('resss $res');
      nombreCompletaPersona =
          '${data.datos['nombres']} ${data.datos['apellidos']}';
    });

    futureNoticias?.then((datos) {
      print('Datos del futureNoticias: $datos');
      if (datos.code == 200) {
        ToastUtil.successfullMessage('Noticias cargadas correctamente');
      } else {
        ToastUtil.errorMessage(datos.tag);
      }
    }).catchError((error) {
      print('Error al recibir los datos del futureLogin: $error');
      ToastUtil.errorMessage(
          'Ocurrió un error al intentar recuperar las noticias');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureNoticias,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.datos == null) {
          return Text('No hay datos disponibles.');
        }

        var listNoticias = snapshot.data!.datos;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onTap: () {
                // Aquí puedes mostrar el menú cuando se hace clic en el texto
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        0, AppBar().preferredSize.height, 0, 0),
                    items: [
                      if (rol == Constants.USUARIO_ROL)
                        const PopupMenuItem(
                            value: 'actualizar',
                            child: Text('Actualizar datos')),
                      if (rol == Constants.ADMIN_ROL)
                        const PopupMenuItem(
                            value: 'usuarios', child: Text('Usuarios')),
                      if (rol == Constants.ADMIN_ROL)
                        const PopupMenuItem(
                            value: 'allcomentarios',
                            child: Text('Todos los comentarios')),
                      const PopupMenuItem(
                          value: 'cerrar_sesion', child: Text('Cerrar sesion')),
                    ]).then((value) {
                  if (value == 'actualizar') {
                    Navigator.pushNamed(
                      context,
                      '/actualizar',
                      arguments: {
                        'externalUser': externalUser,
                        'datosPersona': res
                      },
                    );
                  } else if (value == 'cerrar_sesion') {
                    SecureStorage.delete('token');
                    SecureStorage.delete('external_user');
                    Navigator.pushNamed(context, '/login');
                  } else if (value == 'usuarios') {
                    Navigator.pushNamed(
                      context,
                      '/userlist',
                    );
                  } else if (value == 'allcomentarios') {
                    Navigator.pushNamed(context, '/allcommentsmap');
                  }
                });
              },
              child: Text('Bienvenido, $nombreCompletaPersona',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(32),
            // ! Lista sin tap
            // children: listNoticias
            //     .map<Widget>((noticia) => Card(
            //           key: Key(noticia['external_id']),
            //           elevation: 5,3
            //           margin: const EdgeInsets.symmetric(vertical: 8),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.all(16),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 //* Muestra la imagen
            //                 if (noticia['archivo'] != null)
            //                   Center(
            //                     child: Image.network(
            //                       'http://192.168.1.5:3000/multimedia/${noticia['archivo']}',
            //                       width: 100,
            //                       height: 100,
            //                       fit: BoxFit.cover,
            //                     ),
            //                   ),
            //                 const SizedBox(height: 8),
            //                 Text(
            //                   (noticia['titulo'] != null)
            //                       ? noticia['titulo']
            //                       : 'No hay título',
            //                   style: const TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 8),
            //                 Text(
            //                   (noticia['cuerpo'] != null)
            //                       ? noticia['cuerpo']
            //                       : 'No hay cuerpo',
            //                   style: const TextStyle(fontSize: 16),
            //                 ),
            //                 const SizedBox(height: 8),
            //                 Text(
            //                   (noticia['fecha'] != null)
            //                       ? noticia['fecha']
            //                       : 'Fecha desconocida',
            //                   style: const TextStyle(
            //                     fontSize: 14,
            //                     color: Colors.grey,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ))
            //     .toList(),
            children: listNoticias.map<Widget>((noticia) {
              return GestureDetector(
                  onTap: () {
                    String externalNoticia = noticia['external_id'];
                    print('EL eXT $externalNoticia');
                    if (rol == Constants.USUARIO_ROL) {
                      Navigator.pushNamed(
                        context,
                        '/noticias/detail',
                        arguments: {
                          'externalNoticia': externalNoticia,
                        },
                      );
                    } else if (rol == Constants.ADMIN_ROL) {
                      Navigator.pushNamed(
                        context,
                        '/noticias/detail/admin',
                        arguments: {
                          'externalNoticia': externalNoticia,
                        },
                      );
                    }
                  },
                  child: Card(
                    // key: Key(noticia['external_id']),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //* Muestra la imagen
                          if (noticia['archivo'] != null)
                            Center(
                              child: Image.network(
                                'http://192.168.1.5:3000/multimedia/${noticia['archivo']}',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            (noticia['titulo'] != null)
                                ? noticia['titulo']
                                : 'No hay título',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (noticia['cuerpo'] != null)
                                ? noticia['cuerpo']
                                : 'No hay cuerpo',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (noticia['fecha'] != null)
                                ? noticia['fecha']
                                : 'Fecha desconocida',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            }).toList(),
          ),
        );
      },
    );
  }
}
