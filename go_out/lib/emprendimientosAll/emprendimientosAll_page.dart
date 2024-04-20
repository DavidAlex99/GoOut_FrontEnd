import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'emprendimiento_detalles_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import './comidas_page.dart';
import './eventos_page.dart';
import '../login/auth_service.dart';
import '../login/login_page.dart';

Future<Map> fetchEmprendimientoDetails(int emprendimientoId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  final String url =
      'http://192.168.100.6:8000/goOutApp/emprendimientos/$emprendimientoId';
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

class EmprendimientosPage extends StatefulWidget {
  final String userId;

  EmprendimientosPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EmprendimientosPageState createState() => _EmprendimientosPageState();
}

class _EmprendimientosPageState extends State<EmprendimientosPage> {
  String selectedCategory = 'Todos';
  bool loading = false;
  List<dynamic> emprendimientos = [];

  @override
  void initState() {
    super.initState();
    fetchEmprendimientosInicial();
  }

  fetchEmprendimientosInicial() async {
    try {
      setState(() {
        loading = true;
      });
      final url = 'http://192.168.100.6:8000/goOutApp/emprendimientos' +
          (selectedCategory != 'Todos' ? '?categoria=$selectedCategory' : '');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          emprendimientos = json.decode(response.body);
          print(emprendimientos);
        });
      } else {
        throw Exception('Failed to load emprendimientos');
      }
    } catch (e) {
      print('Error fetching emprendimientos: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  fetchEmprendimientosCercanos() async {
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
        final uri = Uri.http(
            '192.168.100.6:8000', '/goOutApp/emprendimientos/cercanos', {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'categoria': selectedCategory == 'Todos' ? '' : selectedCategory,
        });

        final response = await http.get(uri);

        if (response.statusCode == 200) {
          setState(() {
            emprendimientos = json.decode(response.body);
          });
        } else {
          throw Exception('Failed to load emprendimientos with distances');
        }
      } catch (e) {
        print('Error fetching emprendimientos with distances: $e');
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

  void _logout() async {
    await AuthService().logout(); // Solo llama al método de cerrar sesión
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Redirige al LoginPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emprendimientos'),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue!;
                fetchEmprendimientosInicial();
              });
            },
            items: <String>[
              'Todos',
              'RESTAURANTE',
              'BAR',
              'DISCOTECA',
              'CAFETERIA',
              'TIENDA',
              'SERVICIOS',
              'OTROS',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: fetchEmprendimientosCercanos,
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
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: emprendimientos.length,
              itemBuilder: (context, index) {
                final emprendimiento = emprendimientos[index];
                final distanciaStr = emprendimiento['distancia'] != null
                    ? "${emprendimiento['distancia'].toStringAsFixed(2)} km"
                    : "Distance not available";
                return ListTile(
                  leading: Image.network(
                    emprendimiento['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(emprendimiento['nombre']),
                  subtitle: Text(
                      'Dirección: ${emprendimiento['direccion']}\nDistancia: $distanciaStr'),
                  onTap: () async {
                    try {
                      final emprendimientoDetails =
                          await fetchEmprendimientoDetails(
                              emprendimiento['id']);
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
