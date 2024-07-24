import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './emprendimiento_detalles_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Map> fetchEmprendimientoDetails(int emprendimientoId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  final String url =
      'http://127.0.0.1:8000/goOutApp/emprendimientos/$emprendimientoId';

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

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  String? selectedCategory = 'Todos';
  List<dynamic> eventos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchEventosInicial();
  }

  Future<void> fetchEventosInicial() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print('token en fetchEventoInicial:');
      print(token);

      setState(() {
        loading = true;
      });

      final url = 'http://192.168.100.6:8000/goOutApp/eventos' +
          (selectedCategory != 'Todos' ? '?categoria=$selectedCategory' : '');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          eventos = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load eventos');
      }
    } catch (e) {
      print('Error fetching comidas: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchEventosCercanos() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    if (await Permission.locationWhenInUse.isGranted) {
      try {
        setState(() {
          loading = true;
        });
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token == null) {
          throw Exception('Authentication token not available');
        }

        print('token en fetchEvetosCercanos');
        print(token);

        final uri =
            Uri.https('192.168.100.6:8000', '/goOutApp/eventos/cercanos/', {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'categoria': selectedCategory == 'Todos' ? '' : selectedCategory,
        });

        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            eventos = json.decode(response.body);
          });
        } else {
          throw Exception('Failed to load eventos with distances');
        }
      } catch (e) {
        print('Error fetching comidas with distances: $e');
      } finally {
        setState(() {
          loading = false;
        });
      }
    } else {
      _showLocationPermissionDialog();
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permiso de ubicación requerido"),
          content: Text(
              "Esta función necesita acceso a tu ubicación para calcular distancias."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
                fetchEventosInicial();
              });
            },
            items: <String>[
              'Todos',
              'ARTISTICAS',
              'CULTURALES',
              'DEPORTIVO',
              'AIRE_LIBRE',
              'NOCTURNO',
              'OTRO'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: fetchEventosCercanos,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                var evento = eventos[index];

                String distanciaStr = evento['distancia'] != null
                    ? "${evento['distancia'].toStringAsFixed(2)} km"
                    : "Distancia no disponible";

                var imageUrl = evento['imagenesEvento'] != null &&
                        evento['imagenesEvento'].isNotEmpty
                    ? evento['imagenesEvento'][0]['imagen']
                    : 'https://via.placeholder.com/150';

                return ListTile(
                  title: Text(evento['titulo'] ?? 'No disponible'),
                  subtitle: Row(
                    children: [
                      Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Local: ${evento['emprendimiento_nombre']}'),
                            Text('Precio: ${evento['precio']}'),
                            Text('Disponible: ${evento['disponibles']}'),
                            Text('Distancia: $distanciaStr'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    try {
                      var emprendimientoDetails =
                          await fetchEmprendimientoDetails(
                              evento['emprendimiento_id']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmprendimientoDetallesPage(
                              emprendimiento: emprendimientoDetails),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                );
              },
            ),
    );
  }
}
