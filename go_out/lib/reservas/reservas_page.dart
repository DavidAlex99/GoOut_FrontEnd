import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../reservas/detalle_evento_reserva.dart';

Future<Map> fetchEmprendimientoDetails(int emprendimientoId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

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

class ReservasScreen extends StatefulWidget {
  @override
  _ReservasScreenState createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  List reservas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReservas();
  }

  Future<void> fetchReservas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('userId');

      final response = await http.get(
        Uri.parse('http://192.168.100.6:8000/goOutApp/reservas/$userId'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          reservas = json.decode(response.body);
          print("resewrvas en fetchReservas");
          print(fetchReservas);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reservas');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print("reseras d reserva_page.dart");
    print(reservas);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reservas.isNotEmpty
              ? ListView.builder(
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    var reserva = reservas[index];
                    var evento = reserva['evento'];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(evento['titulo'],
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Descripción: ${evento['descripcion']}'),
                            Text('Cantidad reservada: ${reserva['cantidad']}'),
                            Text('Precio por entrada: \$${evento['precio']}'),
                            Text(
                                'Total pagado: \$${evento['precio'] * reserva['cantidad']}'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventoDetallesPage(
                                  eventoId: reserva['evento']['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              : Center(
                  child: Text('No tienes reservas actualmente'),
                ),
    );
  }
}
