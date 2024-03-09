import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'emprendimiento_detalles_main.dart'; // Asegúrate de crear este archivo.

class EmprendimientosPage extends StatefulWidget {
  @override
  _EmprendimientosPageState createState() => _EmprendimientosPageState();
}

class _EmprendimientosPageState extends State<EmprendimientosPage> {
  final String apiUrl = "http://192.168.100.6:8000/goOutApp/emprendimientos";
  List emprendimientos = [];

  @override
  void initState() {
    super.initState();
    fetchEmprendimientos();
  }

  fetchEmprendimientos() async {
    var response = await http.get(Uri.parse(apiUrl));
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
