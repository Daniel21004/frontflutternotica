import 'package:flutter/material.dart';
import 'package:flutter_noticias/models/Response.dart';
import 'package:flutter_noticias/services/httpServices.dart';
import 'package:flutter_noticias/utils/secureStorage.dart';
import 'package:flutter_noticias/utils/toast.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  Future<Response>? futureUsuarios;
  Future<Response>? futureEstado;
  String externalUser = '';

  @override
  void initState() {
    super.initState();

    iniciarCargaDatos();
  }

  void _actualizar(bool isBanned, String external) {
    setState(() {
      Map<String, dynamic> data = {
        "estado": isBanned,
        "external_id": external,
      };

      print(data);

      setState(() {
        futureEstado = enviar('cuenta/updatestate', false, data);
      });

      futureEstado?.then((datos) {
        print('Datos del futureEstado: $datos');
        if (datos.code == 200) {
          ToastUtil.successfullMessage('Estado actualizado');
          setState(() {
            futureUsuarios = obtener('persona/list', true);
          });
        } else {
          ToastUtil.errorMessage(datos.tag);
        }
      }).catchError((error) {
        print('Error al recibir los datos del futureEstado: $error');
        ToastUtil.errorMessage('Ocurrio un error al actualizar el estado');
      });
    });
  }

  void iniciarCargaDatos() async {
    var usuariosFuture = obtener('persona/list', true);
    externalUser = (await SecureStorage.read(
        'external_user'))!; //! Asegura que NUNCA se obtendra un null

    setState(() {
      futureUsuarios = usuariosFuture;
    });

    futureUsuarios?.then((datos) {
      print('Datos del futureUsuarios: $datos');
      if (datos.code == 200) {
        ToastUtil.successfullMessage('Usuario cargados correctamente');
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
      future: futureUsuarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.datos == null) {
          return Text('No hay datos disponibles.');
        }

        var userList = snapshot.data!.datos;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lista de Usuarios'),
          ),
          body: ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              final isBanned = user['cuenta']['estado'] as bool;
              if (user['external_id'] != externalUser) {
                return ListTile(
                  title: Text('${user['nombres']} ${user['apellidos']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _actualizar(!isBanned, user['cuenta']['external_id']);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: !isBanned ? Colors.red : Colors.green,
                    ),
                    child: Text(
                      !isBanned ? 'Baneado' : 'Activo',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        );
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: UserListPage(),
  ));
}
