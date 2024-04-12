import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './emprendimiento_detalles_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Método inicial que muestra los eventos sin filtro de distancia
  fetchEventosInicial() async {
    setState(() {
      loading = true;
    });

    var url = 'http://192.168.100.6:8000/goOutApp/eventos';
    if (selectedCategory != 'Todos') {
      url += '?categoria=$selectedCategory';
    }

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        eventos = json.decode(response.body);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      print('Failed to load eventos');
    }
  }

  // Método que muestra los eventos con filtro de distancia
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
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        var queryParams = {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'categoria': selectedCategory == 'Todos' ? '' : selectedCategory,
        };
        var uri = Uri.http(
            '192.168.100.6:8000', '/goOutApp/eventos/cercanos', queryParams);

        final response = await http.get(uri);

        if (response.statusCode == 200) {
          setState(() {
            eventos = json.decode(response.body);
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
          });
          // Manejar el error de carga
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
        // Manejar el error
      }
    } else {
      // Manejar el caso en que el usuario no otorga permiso
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
                fetchEventosInicial(); // Refetch with new category but without distance filtering
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
                return ListTile(
                  title: Text(evento['titulo']),
                  subtitle: Text(
                      '${evento['descripcion']} - \$${evento['precio']} - Distancia: $distanciaStr'),
                  leading: evento['imagen'] != null
                      ? Image.network(
                          evento['imagen'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : null,
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
                      print(e); // Manejar el error adecuadamente.
                    }
                  },
                );
              },
            ),
    );
  }
}
