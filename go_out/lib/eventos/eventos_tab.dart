import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detalles_evento_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventosTab extends StatefulWidget {
  final Map emprendimiento;

  EventosTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  _EventosTabState createState() => _EventosTabState();
}

class _EventosTabState extends State<EventosTab> {
  List<dynamic> eventos = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    eventos = widget.emprendimiento['eventos'] ?? [];
  }

  Future<Map> fetchEventoDetails(int eventoId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String url = 'http://192.168.100.6:8000/goOutApp/eventos/$eventoId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load event details');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (eventos.isEmpty) {
      return Center(
        child: Text(
          'No hay eventos disponibles.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        var evento = eventos[index];
        var imagenesEvento = evento['imagenesEvento'] ?? [];
        var imagenUrl = imagenesEvento.isNotEmpty
            ? 'http://192.168.100.6:8000${imagenesEvento[0]['imagen']}'
            : 'https://via.placeholder.com/150';

        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(evento['titulo']),
                subtitle: Text(evento['descripcion']),
                trailing: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () async {
                    try {
                      var eventoDetails =
                          await fetchEventoDetails(evento['id']);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            DetalleEventoPage(evento: eventoDetails),
                      ));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Error al cargar detalles del evento: $e')),
                      );
                    }
                  },
                ),
              ),
              if (imagenesEvento.isNotEmpty)
                Image.network(
                  imagenUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        );
      },
    );
  }
}
