import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../emprendimientosAll/emprendimiento_detalles_main.dart';

Future<Map> fetchEmprendimientoDetails(int emprendimientoId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  final String url =
      'http://192.168.100.6:8000/goOutApp/emprendimientos/$emprendimientoId';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token', // Añadir el encabezado de autorización
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load emprendimiento details');
  }
}

class EventoDetallesPage extends StatefulWidget {
  final int eventoId;

  EventoDetallesPage({Key? key, required this.eventoId}) : super(key: key);

  @override
  _EventoDetallesPageState createState() => _EventoDetallesPageState();
}

class _EventoDetallesPageState extends State<EventoDetallesPage> {
  Map? eventoDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventoDetails();
  }

  Future<void> fetchEventoDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String url =
        'http://192.168.100.6:8000/goOutApp/eventos/${widget.eventoId}';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token', // Añadir el encabezado de autorización
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        eventoDetails = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load event details');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("eventoDetails en detalle_eveno_reseravas");
    print(eventoDetails);
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Evento')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(eventoDetails?['titulo'] ?? '',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(eventoDetails?['descripcion'] ?? '',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Text('Categoría: ${eventoDetails?['categoria'] ?? ''}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Precio: \$${eventoDetails?['precio'] ?? ''}',
                      style: TextStyle(fontSize: 18, color: Colors.redAccent)),
                  SizedBox(height: 10),
                  Text('Disponibles: ${eventoDetails?['disponibles'] ?? ''}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final emprendimientoDetails =
                            await fetchEmprendimientoDetails(
                                eventoDetails?['emprendimiento_id']);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmprendimientoDetallesPage(
                                  emprendimiento: emprendimientoDetails),
                            ));
                      } catch (e) {
                        print('Error navigating to emprendimiento details: $e');
                      }
                    },
                    child: Text('Ver Emprendimiento Asociado'),
                  ),
                  /*
                  Text(
                      'Emprendimiento: ${eventoDetails?['emprendimiento_nombre'] ?? ''}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text(
                      'Dirección: ${eventoDetails?['emprendimiento']['contacto']['direccion'] ?? ''}',
                      style: TextStyle(fontSize: 18)),
                  */

                  // Imágenes del evento
                  ...?eventoDetails?['imagenesEvento']?.map<Widget>((img) {
                    return Image.network(img['imagen'], fit: BoxFit.cover);
                  }).toList(),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final emprendimientoDetails =
                            await fetchEmprendimientoDetails(
                                eventoDetails?['emprendimiento_id']);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmprendimientoDetallesPage(
                                  emprendimiento: emprendimientoDetails),
                            ));
                      } catch (e) {
                        print('Error navigating to emprendimiento details: $e');
                      }
                    },
                    child: Text('Ver Emprendimiento Asociado'),
                  ),
                ],
              ),
            ),
    );
  }
}
