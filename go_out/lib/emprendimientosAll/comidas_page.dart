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

  /*final String url =
      'http://192.168.100.6:8000/goOutApp/emprendimientos/$emprendimientoId';*/
  final String url =
      'https://chillx.onrender.com/goOutApp/emprendimientos/$emprendimientoId';

  final response = await http.get(
    Uri.parse(url),
    headers: token != null ? {'Authorization': 'Token $token'} : {},
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
  List<dynamic> comidas = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchComidasInicial();
  }

  fetchComidasInicial() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token'); // Obtener el token de SharedPreferences
      print('token en fetchComidasInicial:');
      print(token);

      setState(() {
        loading = true;
      });
      /*final url = 'http://192.168.100.6:8000/goOutApp/comidas' +
          (selectedCategory != 'Todos' ? '?categoria=$selectedCategory' : '');*/
      final url = 'https://chillx.onrender.com/goOutApp/comidas' +
          (selectedCategory != 'Todos' ? '?categoria=$selectedCategory' : '');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Token $token', // Añadir el encabezado de autorización
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          comidas = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load comidas');
      }
    } catch (e) {
      print('Error fetching comidas: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  fetchComidasCercanas() async {
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
        String? token = prefs.getString('token'); // Obtener el token guardado

        if (token == null) {
          throw Exception('Authentication token not available');
        }

        print('token en fetchComidasCercanos');
        print(token);

        /*final uri =
            Uri.http('192.168.100.6:8000', '/goOutApp/comidas/cercanas', {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'categoria': selectedCategory == 'Todos' ? '' : selectedCategory,
        });*/

        final uri =
            Uri.https('chillx.onrender.com', '/goOutApp/comidas/cercanas/', {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'categoria': selectedCategory == 'Todos' ? '' : selectedCategory,
        });

        final response = await http.get(
          uri,
          headers: {
            'Authorization':
                'Token $token', // Incluir el token en los encabezados
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            comidas = json.decode(response.body);
          });
        } else {
          throw Exception('Failed to load comidas with distances');
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
          title: Text("Permission Required"),
          content: Text("This feature requires location access to function."),
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
        title: Text('Comidas'),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue!;
                fetchComidasInicial();
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
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: fetchComidasCercanas,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: comidas.length,
              itemBuilder: (context, index) {
                final comida = comidas[index];
                final distanciaStr = comida['distancia'] != null
                    ? "${comida['distancia'].toStringAsFixed(2)} km"
                    : "Distance not available";
                return ListTile(
                  title: Text(comida['nombre']),
                  subtitle: Text(
                      '${comida['descripcion']} - \$${comida['precio']} - Distancia: $distanciaStr'),
                  leading: comida['imagen'] != null
                      ? Image.network(comida['imagen'],
                          width: 100, height: 100, fit: BoxFit.cover)
                      : null,
                  onTap: () async {
                    try {
                      final emprendimientoDetails =
                          await fetchEmprendimientoDetails(
                              comida['emprendimiento_id']);
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
                );
              },
            ),
    );
  }
}
