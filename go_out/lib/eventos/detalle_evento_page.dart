import 'package:flutter/material.dart';

class DetalleEventoPage extends StatelessWidget {
  final Map evento;

  DetalleEventoPage({required this.evento});

  @override
  Widget build(BuildContext context) {
    List imagenesEvento = evento['imagenesEvento'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(evento['titulo']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evento['descripcion'],
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...imagenesEvento.map((img) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Image.network(img['imagen'], fit: BoxFit.cover),
              );
            }).toList(),
            // Aquí puedes agregar más detalles como la fecha del evento, lugar, etc.
          ],
        ),
      ),
    );
  }
}
