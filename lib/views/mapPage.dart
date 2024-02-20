import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  // * Parametros
  final dynamic comentarios;

  const MapPage({
    Key? key,
    required this.comentarios,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-3.994659, -79.208287), // Ubicación inicial del mapa
          zoom: 13.0, // Nivel de zoom inicial
        ),
        nonRotatedChildren: [
          AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributers', onSourceTapped: null)
        ],
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: widget.comentarios.map<Marker>((comentario) {
              print('comentarioooooo $comentario');
              return Marker(
                point: comentario['coordenadas'],
                width: 100.0,
                height: 80.0,
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    showDialog(
                      context: ctx,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Información del comentario'),
                          content: Text(
                              'Cuerpo: ${comentario['cuerpo']}\nAutor: ${comentario['nombresPersona']}\nFecha:${comentario['fecha']}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
