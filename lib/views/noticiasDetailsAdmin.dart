import 'package:flutter/material.dart';
import 'package:flutter_noticias/models/Response.dart';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:flutter_noticias/views/mapPage.dart';
import 'package:latlong2/latlong.dart';

class NoticiaDetailAdminPage extends StatefulWidget {
  // * Parametros
  final String externalNoticia;

  const NoticiaDetailAdminPage({
    Key? key,
    required this.externalNoticia,
  }) : super(key: key);

  @override
  _NoticiaDetailAdminPageState createState() => _NoticiaDetailAdminPageState();
}

class _NoticiaDetailAdminPageState extends State<NoticiaDetailAdminPage> {
  Future<Response>? futureComentario;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future:
          obtener('comentario/list/noticia/${widget.externalNoticia}', false),
      builder: (context, comentariosSnapshot) {
        if (comentariosSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (comentariosSnapshot.hasError) {
          return Text('Error: ${comentariosSnapshot.error}');
        } else if (!comentariosSnapshot.hasData ||
            comentariosSnapshot.data!.datos == null) {
          return const Text('No hay comentarios disponibles.');
        } else {
          // Aquí puedes construir la lista de comentarios utilizando los datos de comentariosSnapshot
          List<Map<String, dynamic>> comentariosFormater = comentariosSnapshot
              .data!.datos
              .map<Map<String, dynamic>>((comentario) {
            return {
              'cuerpo': comentario['cuerpo'],
              'coordenadas': LatLng(
                double.parse('${comentario['latitud']}'),
                double.parse('${comentario['longitud']}'),
              ),
              'nombresPersona':
                  '${comentario['persona']['nombres']} ${comentario['persona']['apellidos']}',
              'fecha': comentario['fecha'],
            };
          }).toList();

          return MapPage(comentarios: comentariosFormater);
        }
      },
    );
  }
}
