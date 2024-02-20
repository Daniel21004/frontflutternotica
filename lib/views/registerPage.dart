import 'package:flutter/material.dart';

//* importaciones importantes
// import 'dart:developer';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:flutter_noticias/utils/toast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //! OJo el form_key
  final _formkey = GlobalKey<FormState>();
  Future<dynamic>? futureRegistro;

  //* Campos para crear persona
  final TextEditingController correo = TextEditingController();
  final TextEditingController clave = TextEditingController();
  final TextEditingController nombres = TextEditingController();
  final TextEditingController apellidos = TextEditingController();

  void _registrarse() {
    setState(() {
      if (_formkey.currentState!.validate()) {
        Map<String, String> data = {
          "correo": correo.text,
          "clave": clave.text,
          "nombres": nombres.text,
          "apellidos": apellidos.text,
        };

        setState(() {
          futureRegistro = enviar('persona/save', false, data);
        });

        futureRegistro?.then((datos) {
          print('Datos del futureLogin: $datos');
          if (datos.code == 200) {
            ToastUtil.successfullMessage('Registro exitoso');
            Navigator.pushNamed(context, '/login');
          } else {
            print('regist $datos');
            ToastUtil.errorMessage(datos.tag);
          }
        }).catchError((error) {
          print('Error al recibir los datos del futureLogin: $error');
          ToastUtil.errorMessage('ocurrio un error al intentar registrarse');
        });

        print('SESION OK');
      } else {
        print('no hubo registro');
        ToastUtil.errorMessage('Por favor, rellene los campos');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Scaffold(
          body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: const Text("Noticias",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 30)),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: const Text("Registro",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 20)),
          ),
          Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: nombres,
                validator: (value) {
                  if (value.toString().isEmpty) {
                    return "Debe ingresar sus nombres";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Nombres'),
              )),
          Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: apellidos,
                validator: (value) {
                  if (value.toString().isEmpty) {
                    return "Debe ingresar sus apellidos";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Apellidos'),
              )),
          Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: correo,
                validator: (value) {
                  if (value.toString().isEmpty) {
                    return "Debe ingresar su correo";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'Correo',
                    suffixIcon: Icon(Icons.alternate_email)),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
                obscureText: true, // Para ocultar la contraseña
                controller: clave,
                validator: (value) {
                  if (value.toString().isEmpty) {
                    return "Debe ingresar una clave";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'Clave', suffixIcon: Icon(Icons.key))),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: ElevatedButton(
              onPressed: _registrarse,
              child: const Text('Registrarse'),
            ),
          ),
          Row(
            children: <Widget>[
              const Text('Ya tienes una cuenta?'),
              TextButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/home');
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Iniciar sesion',
                    style: TextStyle(fontSize: 20),
                  ))
            ],
          )
        ],
      )),
    );
  }
}
