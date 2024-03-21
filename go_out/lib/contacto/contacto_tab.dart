import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContactoTab extends StatefulWidget {
  final Map emprendimiento;

  ContactoTab({required this.emprendimiento});

  @override
  _ContactoTabState createState() => _ContactoTabState();
}

class _ContactoTabState extends State<ContactoTab> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Contacto en contactoDetalle: ${widget.emprendimiento['contacto'].toString()}");
    final contacto = widget.emprendimiento['contacto'] ?? {};
    final imagenesContacto = contacto['imagenesContacto'] ?? [];

    final latitud = double.tryParse('${contacto['latitud']}');
    final longitud = double.tryParse('${contacto['longitud']}');

    if (latitud == null || longitud == null) {
      print("Error: Las coordenadas no son válidas.");
      return Center(child: Text("Ubicación del emprendimiento no disponible."));
    } else {
      print(
          "Coordenadas del emprendimiento: Latitud: $latitud, Longitud: $longitud");
    }

    final LatLng emprendimientoLocation = LatLng(latitud, longitud);

    return SingleChildScrollView(
      child: Column(
        children: [
          if (latitud != null && longitud != null)
            Container(
              height: 300.0,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: emprendimientoLocation,
                  zoom: 16.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('emprendimientoMarker'),
                    position: emprendimientoLocation,
                  ),
                },
              ),
            ),
          ListTile(
            title: Text('Dirección:'),
            subtitle: Text(contacto['direccion'] ?? 'No disponible'),
            leading: Icon(Icons.location_on),
          ),
          ListTile(
            title: Text('Teléfono:'),
            subtitle: Text(contacto['telefono'] ?? 'No disponible'),
            leading: Icon(Icons.phone),
          ),
          ListTile(
            title: Text('Correo Electrónico:'),
            subtitle: Text(contacto['correo'] ?? 'No disponible'),
            leading: Icon(Icons.email),
          ),
          // Aquí mostramos las imágenes sin usar CarouselSlider
          for (var img in imagenesContacto)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.network(
                img['imagen'],
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
