import 'package:flutter/material.dart';

class MiPagina extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Mi App'), // Título del AppBar
          actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})], // Acciones del AppBar
      ),
      body: MiContenido(), // Contenido de la página
    );
  }
}

class MiContenido extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Contenido de la página aquí'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MiPagina(),
  ));
}
