import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//* importaciones importantes
// import 'dart:developer';


class Page404 extends StatefulWidget {
  const Page404({ Key? key }) : super(key: key);

  @override
  _Page404State createState() => _Page404State();
}

class _Page404State extends State<Page404> {
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 404'),
      ),
      body: const Text('NO SE ENCONTRO LA PAGINA'),
    );
  }
}