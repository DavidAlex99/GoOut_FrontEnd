import 'package:flutter/material.dart';
import 'detalle_evento_page.dart'; // Asegúrate de crear este archivo para mostrar los detalles del evento.

class EventosTab extends StatelessWidget {
  final Map emprendimiento;

  EventosTab({required this.emprendimiento});

  @override
  Widget build(BuildContext context) {
    List eventos = emprendimiento['eventos'] ?? [];

    return ListView.builder(
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        var evento = eventos[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(evento['titulo']),
            subtitle: Text(
                'Disponibles: ${evento['disponibles']} - Precio: \$${evento['precio']}'),
            children: [
              Column(
                children: evento['imagenesEvento'].map<Widget>((img) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Image.network(img['imagen'], fit: BoxFit.cover),
                  );
                }).toList(),
              ),
              TextButton(
                child: Text('Ver detalles'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleEventoPage(evento: evento),
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
