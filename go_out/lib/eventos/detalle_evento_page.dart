import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleEventoPage extends StatefulWidget {
  final Map evento;

  DetalleEventoPage({required this.evento}) {
    print("Evento recibido en constructor: $evento");
  }

  @override
  _DetalleEventoPageState createState() => _DetalleEventoPageState();
}

class _DetalleEventoPageState extends State<DetalleEventoPage> {
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = false;

  void mostrarDetallesReserva(BuildContext context, Map reserva) {
    print("Evento recibido en constructor: $reserva");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reserva realizada con éxito'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Evento: ${reserva['evento']['titulo']}'),
                Text('Cantidad reservada: ${reserva['cantidad']}'),
                // Agregar más detalles si son necesarios
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reservarPlazas() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final Uri apiUrl =
        Uri.parse("http://192.168.100.6:8000/goOutApp/reservas/crear/");

    if (token == null) {
      print('Token no disponible');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    print('Token disponible: $token');
    print('ID del evento a reservar: ${widget.evento['id']}');
    print('Cantidad de plazas a reservar: ${_cantidadController.text}');

    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'evento': widget.evento['id'],
        'cantidad': int.tryParse(_cantidadController.text) ?? 0,
      }),
    );

    print('Estado de la respuesta: ${response.statusCode}');
    print('Cuerpo de la respuesta: ${response.body}');

    if (response.statusCode == 201) {
      // funcionalidad: devoluciosn de datos de reserva al cliente
      // final reserva = json.decode(response.body);
      // mostrarDetallesReserva(context, reserva);
      // fin funccionalidad: devoluciosn de datos de reserva al cliente

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva realizada con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al realizar la reserva')),
      );
      // Además, podrías querer manejar diferentes tipos de errores según el código de estado de la respuesta.
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List imagenesEvento = widget.evento['imagenesEvento'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evento['titulo']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.evento['descripcion'],
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              ...imagenesEvento.map((img) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Image.network(img['imagen'], fit: BoxFit.cover),
                  )),
              TextField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad de plazas a reservar',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _reservarPlazas,
                      child: Text('Reservar Plazas'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
