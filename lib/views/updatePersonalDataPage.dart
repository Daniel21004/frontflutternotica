import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_noticias/models/Response.dart';

//* importaciones importantes
// import 'dart:developer';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:flutter_noticias/utils/toast.dart';

class UpdatePersonalDataPage extends StatefulWidget {
  // * Parametros
  final String externalUser;
  final Response datosPersona;

  // const UpdatePersonalDataPage({Key? key}) : super(key: key);
  const UpdatePersonalDataPage({
    Key? key,
    required this.externalUser,
    required this.datosPersona,
  }) : super(key: key);

  @override
  _UpdatePersonalDataPageState createState() => _UpdatePersonalDataPageState();
}

class _UpdatePersonalDataPageState extends State<UpdatePersonalDataPage> {
  //! OJo el form_key
  final _formkey = GlobalKey<FormState>();
  Future<dynamic>? futureUpdate;

  //* Campos para actualizar persona
  final TextEditingController celular = TextEditingController();
  final TextEditingController direccion = TextEditingController();
  String fechaNacimiento = '';
  final TextEditingController nombres = TextEditingController();
  final TextEditingController apellidos = TextEditingController();

  @override
  void initState() {
    super.initState();
    // * Asignación de valores iniciales
    nombres.text = widget.datosPersona.datos['nombres'];
    apellidos.text = widget.datosPersona.datos['apellidos'];
    celular.text = widget.datosPersona.datos['celular'];
    direccion.text = widget.datosPersona.datos['direccion'];
    // fechaNacimiento = widget.datosPersona.datos['fecha_nacimiento'] == null ? '' : widget.datosPersona.datos['fecha_nacimiento'];
    fechaNacimiento = widget.datosPersona.datos['fecha_nacimiento'] == null ? '' : widget.datosPersona.datos['fecha_nacimiento'];
  }

  void _actualizar() {
    setState(() {
      if (_formkey.currentState!.validate()) {
        Map<String, String> data = {
          "celular": celular.text,
          "direccion": direccion.text,
          "fecha_nacimiento": fechaNacimiento.substring(0, 10),
          "nombres": nombres.text,
          "apellidos": apellidos.text,
          "external_id": widget
              .externalUser // * Asignación del external para la actualización
        };

        print(data);

        setState(() {
          futureUpdate = enviar('persona/update', false, data);
        });

        futureUpdate?.then((datos) {
          print('Datos del futureUpdate: $datos');
          if (datos.code == 200) {
            ToastUtil.successfullMessage('Se actualizaron los datos con exito');
            Navigator.pushNamed(context, '/noticias');
          } else {
            ToastUtil.errorMessage(datos.tag);
          }
        }).catchError((error) {
          print('Error al recibir los datos del futureLogin: $error');
          ToastUtil.errorMessage(
              'Ocurrio un error al intentar actualizar los datos');
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
    // ! Validar el envio de los parametros
    // print('Parametro 1: ${widget.externalUser}');
    // print('Parametro 2: ${widget.datosPersona}');

    return Form(
      key: _formkey,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Actualizar datos'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(32),
            children: <Widget>[
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
                    controller: celular,
                    validator: (value) {
                      if (value.toString().isEmpty) {
                        return "Debe ingresar su celular";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Celular'),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                    controller: direccion,
                    validator: (value) {
                      if (value.toString().isEmpty) {
                        return "Debe ingresar una direccion";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Direccion')),
              ),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: InputDatePickerFormField(
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 36000)),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                    initialDate: DateFormat('yyyy-MM-dd').parse(
                        fechaNacimiento), // ! Se parsea en el formato en como se trae la fecha
                    errorFormatText: 'Ingrese un formato correcto de fecha',
                    onDateSaved: (value) => {
                      setState(() {
                        fechaNacimiento = value.toString();
                      })
                    },
                  )),
              Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: ElevatedButton(
                  onPressed: () => {
                    _formkey.currentState
                        ?.save(), // ! Importante para que funcion el input date
                    _actualizar()
                  },
                  child: const Text('Actualizar'),
                ),
              ),
            ],
          )),
    );
  }
}
