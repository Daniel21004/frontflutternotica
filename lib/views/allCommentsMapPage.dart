import 'package:flutter/material.dart';
import 'package:flutter_noticias/models/Response.dart';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:flutter_noticias/views/mapPage.dart';
import 'package:latlong2/latlong.dart';

class AllCommentsMapPage extends StatefulWidget {
  const AllCommentsMapPage({Key? key}) : super(key: key);

  @override
  _AllCommentsMapPageState createState() => _AllCommentsMapPageState();
}

class _AllCommentsMapPageState extends State<AllCommentsMapPage> {
  Future<Response>? futureComentarios;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future:
          obtener('comentario/list/', false),
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
                comentario['latitud'],
                comentario['longitud'],
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
