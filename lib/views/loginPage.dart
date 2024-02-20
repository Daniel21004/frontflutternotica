import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_noticias/utils/Constants.dart';
import 'package:flutter_noticias/utils/toast.dart';
import 'package:flutter_noticias/utils/secureStorage.dart';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; //! Dependencia para decodificar un token

//* Importación necesaria
// import 'dart:developer';
// import 'package:validators/validators.dart'; // Da problemas al validar correos como gerente@gerente.com

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Future<dynamic> futureResponse;
  Future<dynamic>? futureLogin;

  //? Formkey para el formulario. privada _
  final _formkey = GlobalKey<FormState>();

  //* variables para validacion
  final TextEditingController correoControl = TextEditingController();
  final TextEditingController claveControl = TextEditingController();

  void _iniciarSesion() {
    if (_formkey.currentState!.validate()) {
      Map<String, String> mapa = {
        "correo": correoControl.text,
        "clave": claveControl.text,
      };

      print(mapa);

      setState(() {
        // Ejecuta la llamada al login
        futureLogin = enviar('cuenta/login', false, mapa);
      });

      futureLogin?.then((data) {
        print('Datos del futureLogin: $data');
        if (data.code == 200) {
          // * Decodificación del token
          Map<String, dynamic>? decodedToken =
              JwtDecoder.decode(data.datos['token']!);

          String? rol = decodedToken['rol'];
          print('Correo electrónico: $rol');

          SecureStorage.save('rol', rol);
          SecureStorage.save('token', data.datos['token']);
          SecureStorage.save('external_user', data.datos['external_user']);
          ToastUtil.successfullMessage('Sesion iniciada correctamente');

          if (rol == Constants.USUARIO_ROL) {
            Navigator.pushNamed(context, '/noticias');
          } else if (rol == Constants.ADMIN_ROL) {
            Navigator.pushNamed(context, '/noticias');
          } else {
            ToastUtil.errorMessage('Error al decodificar token');
          }
        } else {
          ToastUtil.errorMessage(data.tag);
        }
      }).catchError((error) {
        print('Error al recibir los datos del futureLogin: $error');
        ToastUtil.errorMessage('ocurrio un error al intentar iniciar sesión');
      });

      print('SESION OK');
    } else {
      print('no inciio sesion');
      ToastUtil.errorMessage('Por favor, rellene los campos');
    }
  }

  @override
  void initState() {
    super.initState();
    // CODIGO que se quiera ejecutar al iniciar la aplicacion
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey, //* Asignación del key
      child: Scaffold(
        body: ListView(
          // body: Center(
          padding: const EdgeInsets.all(32),
          // child: FutureBuilder<Response>(
          // // child: FutureBuilder<Album>(
          //   future: futureResponse,
          //   // future: futureAlbum,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return Text(snapshot.data!.datos.toString());
          //     } else if (snapshot.hasError) {
          //       return Text('${snapshot.error}');
          //     }

          //     // By default, show a loading spinner.
          //     return const CircularProgressIndicator();
          //   },
          // )

          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text("Inicio de sesion",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)),
            ),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: correoControl,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Debe ingresar su correo";
                    }
                    return null;
                    //! No me valida mi correo gerente@gerente.com
                    // if (isEmail(value.toString())) {
                    //   return "Debe ser un correo valido";
                    // }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Correo',
                      suffixIcon: Icon(Icons.alternate_email)),
                )),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  obscureText: true, // Para ocultar la contraseña
                  controller: claveControl,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Debe ingresar una clave";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Clave', suffixIcon: Icon(Icons.key)),
                )),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                onPressed: _iniciarSesion,
                child: const Text('Inicio'),
              ),
            ),
            Row(
              children: <Widget>[
                const Text('No tienes una cuenta?'),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            ),
            //! Eliminar
            // FutureBuilder<dynamic>(
            //   future: futureLogin,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Text(snapshot.data!.toString());
            //     } else if (snapshot.hasError) {
            //       return Text('${snapshot.error}');
            //     }

            //     // By default, show a loading spinner.
            //     return const CircularProgressIndicator();
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
