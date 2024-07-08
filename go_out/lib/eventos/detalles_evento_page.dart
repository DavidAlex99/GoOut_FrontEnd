import 'package:flutter/material.dart';
import './pago_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetalleEventoPage extends StatefulWidget {
  final Map evento;

  DetalleEventoPage({Key? key, required this.evento}) : super(key: key);

  @override
  _DetalleEventoPageState createState() => _DetalleEventoPageState();
}

class _DetalleEventoPageState extends State<DetalleEventoPage> {
  final TextEditingController _cantidadController = TextEditingController();
  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _handleReservation() async {
    if (_cantidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Por favor, ingresa una cantidad."),
      ));
      return;
    }

    int cantidad = int.parse(_cantidadController.text);
    if (cantidad > widget.evento['disponibles']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No hay suficientes plazas disponibles."),
      ));
      return;
    }

    double total = cantidad * double.parse(widget.evento['precio'].toString());

    // Aquí podrías añadir la lógica para redirigir al usuario a una pantalla de pago
    // Por ejemplo, pasando la cantidad y el total al método que gestiona el pago
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          precio: total,
          eventoId: widget.evento['id'],
          cantidad: cantidad,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> imagenesEvento = widget.evento['imagenesEvento'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evento['titulo'] ?? 'Detalles del Evento'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagenesEvento.isNotEmpty)
              Column(
                children: imagenesEvento.map((img) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.network(
                      img['imagen'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Text('No se pudo cargar la imagen');
                      },
                    ),
                  );
                }).toList(),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Otros detalles del evento...
                  TextField(
                    controller: _cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad de Plazas',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _handleReservation,
                    child: Text('Reservar y Pagar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
