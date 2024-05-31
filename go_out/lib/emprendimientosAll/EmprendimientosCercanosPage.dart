import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'emprendimiento_detalles_main.dart'; // Asegúrate de que esta ruta sea correcta.

class EmprendimientosCercanosPage extends StatefulWidget {
  @override
  _EmprendimientosCercanosPageState createState() =>
      _EmprendimientosCercanosPageState();
}

class _EmprendimientosCercanosPageState
    extends State<EmprendimientosCercanosPage> {
  List<dynamic> emprendimientosCercanos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchEmprendimientosInicial();
  }

  fetchEmprendimientosInicial() async {
    final response = await http
        .get(Uri.parse('http://192.168.100.6:8000/goOutApp/emprendimientos'));
    if (response.statusCode == 200) {
      _parseEmprendimientos(response.body);
    } else {
      if (mounted) {
        setState(() {
          loading = false;
        });
        // Manejar el error de carga
      }
    }
  }

  void _parseEmprendimientos(String responseBody) {
    compute(_parseEmprendimientosInBackground, responseBody).then((result) {
      if (mounted) {
        setState(() {
          emprendimientosCercanos = result;
          loading = false;
        });
      }
    });
  }

  static List<dynamic> _parseEmprendimientosInBackground(String responseBody) {
    return json.decode(responseBody).cast<Map<String, dynamic>>();
  }

  Future<void> fetchEmprendimientosCercanos() async {
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
        final response = await http.get(Uri.parse(
            'http://192.168.100.6:8000/goOutApp/emprendimientos/cercanos/?lat=${position.latitude}&lon=${position.longitude}'));

        if (response.statusCode == 200) {
          _parseEmprendimientos(response.body);
        } else {
          if (mounted) {
            setState(() {
              loading = false;
            });
            // Manejar el error de carga
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            loading = false;
          });
          // Manejar el error
        }
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
        title: Text('Emprendimientos Cercanos'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: emprendimientosCercanos.length,
                    itemBuilder: (context, index) {
                      var emprendimiento = emprendimientosCercanos[index];
                      String distanciaStr = emprendimiento['distancia'] != null
                          ? "${emprendimiento['distancia'].toStringAsFixed(2)} km"
                          : "Distancia no disponible";
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
                ),
                if (!loading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: fetchEmprendimientosCercanos,
                      child: Text('Calcular distancias'),
                    ),
                  ),
              ],
            ),
    );
  }
}
