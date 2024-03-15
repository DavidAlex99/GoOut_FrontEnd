import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'emprendimiento_detalles_main.dart';
import './comidas_page.dart';
import './eventos_page.dart';

class EmprendimientosPage extends StatefulWidget {
  final String userId; // Agrega esta línea

  EmprendimientosPage({Key? key, required this.userId})
      : super(key: key); // Modifica esta línea

  @override
  _EmprendimientosPageState createState() => _EmprendimientosPageState();
}

class _EmprendimientosPageState extends State<EmprendimientosPage> {
  final String apiUrl = "http://192.168.100.6:8000/goOutApp/emprendimientos";
  List emprendimientos = [];
  String? selectedCategory = null; // Almacena la categoría seleccionada
  List<String> categories = [
    'Todos',
    'REST',
    'BAR',
    'DISCO',
    'CAFE',
    'TIENDA',
    'SERV',
    'OTRO'
  ]; // Lista de categorías para el filtro

  @override
  void initState() {
    super.initState();
    fetchEmprendimientos();
  }

  fetchEmprendimientos() async {
    // Modificacion de la url para realizar el filtro
    String filterUrl = apiUrl;
    if (selectedCategory != null && selectedCategory != 'Todos') {
      filterUrl += '?categoria=$selectedCategory';
    }
    var response = await http.get(Uri.parse(filterUrl));
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;
      setState(() {
        emprendimientos = data;
      });
    } else {
      throw Exception('Failed to load emprendimientos');
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
            underline: Container(), // Elimina la línea subyacente del Dropdown
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                fetchEmprendimientos(); // Refetch los emprendimientos con el filtro aplicado
              });
            },
            items: categories.map<DropdownMenuItem<String>>((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () {
              // Navegación a ComidasPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComidasPage()),
              );
            },
          ),
          // navegacion a eventos
          IconButton(
            icon: Icon(Icons.party_mode),
            onPressed: () {
              // Navegación a ComidasPage
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
