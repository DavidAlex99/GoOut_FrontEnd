// Asegúrate de importar los paquetes necesarios
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './emprendimiento_detalles_main.dart';

Future<Map> fetchEmprendimientoDetails(int emprendimientoId) async {
  final String url =
      'http://192.168.100.6:8000/goOutApp/emprendimientos/$emprendimientoId';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load emprendimiento details');
  }
}

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  String? selectedCategory = 'Todos';
  List eventos = [];

  @override
  void initState() {
    super.initState();
    fetchEventos();
  }

  fetchEventos() async {
    var url =
        'http://192.168.100.6:8000/goOutApp/eventos'; // Asegúrate de que esta URL es correcta
    if (selectedCategory != 'Todos') {
      url += '?categoria=$selectedCategory';
    }
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        eventos = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load eventos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Eventos'),
          actions: <Widget>[
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                  fetchEventos();
                });
              },
              items: <String>['Todos', 'ARTISTICAS', 'CULTURALES', 'DEPORTIVO']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: eventos.length,
          itemBuilder: (context, index) {
            var evento = eventos[index];
            return ListTile(
              title: Text(evento['titulo']),
              subtitle:
                  Text('${evento['descripcion']} - \$${evento['precio']}'),
              onTap: () async {
                try {
                  var emprendimientoDetails = await fetchEmprendimientoDetails(
                      evento['emprendimiento_id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmprendimientoDetallesPage(
                          emprendimiento: emprendimientoDetails),
                    ),
                  );
                } catch (e) {
                  // Manejar el error, por ejemplo, mostrando un mensaje al usuario
                  print(
                      e); // Considera usar un enfoque más robusto para manejar y reportar errores
                }
              },
            );
          },
        ));
  }
}
