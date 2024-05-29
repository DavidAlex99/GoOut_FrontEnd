import 'package:flutter/material.dart';
import 'detalles_evento_page.dart'; // Asegúrate de haber creado este archivo.

class EventosTab extends StatelessWidget {
  final Map emprendimiento;

  EventosTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> eventos = emprendimiento['eventos'] ?? [];

    if (eventos.isEmpty) {
      return Center(
        child: Text(
          'No hay información disponible en la sección Eventos.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        var evento = eventos[index];
        var imagenesEvento = evento['imagenesEvento'] ?? [];
        var imagenUrl = imagenesEvento.isNotEmpty
            ? imagenesEvento[0]['imagen']
            : 'https://via.placeholder.com/150'; // Imagen por defecto si no hay imágenes

        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(evento['titulo']),
                subtitle: Text(evento['descripcion']),
                trailing: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    // Navegar a la página de detalles del evento
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DetalleEventoPage(evento: evento),
                    ));
                  },
                ),
              ),
              if (imagenesEvento.isEmpty)
                Text(
                  'No hay imágenes disponibles en la galería.',
                  style: Theme.of(context).textTheme.bodyText2,
                )
              else
                ...imagenesEvento.map((imagen) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.network(
                      imagen['imagen'],
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }
}
