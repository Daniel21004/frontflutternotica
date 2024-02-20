import 'package:flutter_noticias/utils/secureStorage.dart';
import 'package:http/http.dart' as http;
// import 'package:primera_app/controls/utils/Utiles.dart';

import 'dart:convert';
import 'dart:async';
import 'package:flutter_noticias/models/Response.dart';

// const String URL = 'http://10.20.138.100:3000/';
const String URL = 'http://192.168.1.5:3000/';
const String URL_MEDIA = URL + '/public';

// 'http://10.0.2.2:3000/rol/obtener/5d180082-fff2-4cb7-9f13-349ce0492714')); //EMulador
// 'http://192.168.1.5:3000/rol/obtener/5d180082-fff2-4cb7-9f13-349ce0492714')); // Fisico

Future<Response> obtener(String recurso, bool token) async {
  Map<String, String> _header = {};
  Map<String, dynamic> _response = {};

  if (token) {
    String tokenA = (await SecureStorage.read('token'))!; //! Asegura que NUNCA se obtendra un null
    _header = {'jwt': tokenA};
  }

  final String _url = URL + recurso;
  final uri = Uri.parse(_url);

  final response = await http.get(uri, headers: _header);

  _response = jsonDecode(response.body) as Map<String, dynamic>;
  _response['code'] = response.statusCode;

  return Response.fromJson(_response as Map<String, dynamic>);
}

Future<Response> enviar(String recurso, bool token, dynamic cuerpo) async {
  Map<String, String> _header = {
    'Content-Type': 'application/json; charset=UTF-8'
  };
  Map<String, dynamic> _response = {};

if (token) {
    String tokenA = (await SecureStorage.read('token'))!; //! Asegura que NUNCA se obtendra un null
    _header = {'jwt': tokenA};
  }

  final String _url = URL + recurso;
  final uri = Uri.parse(_url);

  final response =
      await http.post(uri, headers: _header, body: jsonEncode(cuerpo));

  _response = jsonDecode(response.body) as Map<String, dynamic>;
  _response['code'] = response.statusCode;

  return Response.fromJson(_response as Map<String, dynamic>);
}
