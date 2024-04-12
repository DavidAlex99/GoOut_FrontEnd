import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'emprendimiento_detalles_main.dart'; // Asegúrate de que esta ruta es correcta
import './comidas_page.dart'; // Asegúrate de que esta ruta es correcta
import './eventos_page.dart'; // Asegúrate de que esta ruta es correcta
import 'package:shared_preferences/shared_preferences.dart';
import './EmprendimientosCercanosPage.dart';

class EmprendimientosPage extends StatefulWidget {
  final String userId;

  EmprendimientosPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EmprendimientosPageState createState() => _EmprendimientosPageState();
}

class _EmprendimientosPageState extends State<EmprendimientosPage> {
  final String apiUrl = "http://192.168.100.6:8000/goOutApp/emprendimientos";
  List<dynamic> emprendimientos = [];
  String? selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    fetchEmprendimientos();
  }

  fetchEmprendimientos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
        'auth_token'); // Usa aquí la misma clave que usaste para guardar el token

    String filterUrl = apiUrl;
    if (selectedCategory != null && selectedCategory != 'Todos') {
      filterUrl += '?categoria=$selectedCategory';
    }

    var response = await http.get(
      Uri.parse(filterUrl),
      headers: token != null
          ? {
              'Content-Type': 'application/json',
              'Authorization': 'Token $token',
            }
          : {
              'Content-Type': 'application/json',
            },
    );

    if (response.statusCode == 200) {
      setState(() {
        emprendimientos = json.decode(response.body);
      });
    } else {
      print('Failed to load emprendimientos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emprendimientos'),
        actions: <Widget>[
          DropdownButton<String>(
            value: selectedCategory,
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
                fetchEmprendimientos();
              });
            },
            items: <String>[
              'Todos',
              'REST',
              'BAR',
              'DISCO',
              'CAFE',
              'TIENDA',
              'SERV',
              'OTRO'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.near_me),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmprendimientosCercanosPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComidasPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.party_mode),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventosPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: emprendimientos.length,
        itemBuilder: (context, index) {
          var emprendimiento = emprendimientos[index];
          return ListTile(
            leading: Image.network(
              emprendimiento['imagen'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            title: Text(emprendimiento['nombre']),
            subtitle: Text('Categoría: ${emprendimiento['categoria']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmprendimientoDetallesPage(
                      emprendimiento: emprendimiento),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
