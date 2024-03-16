import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './emprendimiento_detalles_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map> fetchEmprendimientoDetails(int emprendimientoId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  final String url =
      'http://192.168.100.6:8000/goOutApp/emprendimientos/$emprendimientoId';
  final response = await http.get(
    Uri.parse(url),
    headers: token != null
        ? {
            'Authorization': 'Token $token',
          }
        : {},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load emprendimiento details');
  }
}

class ComidasPage extends StatefulWidget {
  @override
  _ComidasPageState createState() => _ComidasPageState();
}

class _ComidasPageState extends State<ComidasPage> {
  String? selectedCategory = 'Todos';
  List comidas = [];

  @override
  void initState() {
    super.initState();
    fetchComidas();
  }

  // metodo para sincronizacion de todas las comidas
  fetchComidas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
        'auth_token'); // Asegúrate de que 'auth_token' sea la clave correcta para tu token

    var url = 'http://192.168.100.6:8000/goOutApp/comidas';
    if (selectedCategory != 'Todos') {
      url += '?categoria=$selectedCategory';
    }

    var response = await http.get(
      Uri.parse(url),
      headers: token != null
          ? {
              'Authorization': 'Token $token',
            }
          : {},
    );

    if (response.statusCode == 200) {
      setState(() {
        comidas = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load comidas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comidas'),
        actions: <Widget>[
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue;
                fetchComidas();
              });
            },
            items: <String>[
              'Todos',
              'ENTRANTE',
              'PRINCIPAL',
              'POSTRE',
              'BEBIDA',
              'SNACKS',
              'OTRO'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: comidas.length,
        itemBuilder: (context, index) {
          var comida = comidas[index];
          return ListTile(
            title: Text(comida['nombre']),
            subtitle: Text('${comida['descripcion']} - \$${comida['precio']}'),
            leading: comida['imagen'] != null
                ? Image.network(
                    comida['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : null,
            onTap: () async {
              try {
                var emprendimientoDetails = await fetchEmprendimientoDetails(
                    comida['emprendimiento_id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmprendimientoDetallesPage(
                        emprendimiento: emprendimientoDetails),
                  ),
                );
              } catch (e) {
                print(
                    e); // Considera usar un enfoque más adecuado para manejar y reportar errores.
              }
            },
          );
        },
      ),
    );
  }
}
