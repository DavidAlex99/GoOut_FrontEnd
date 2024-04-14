import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class ContactoTab extends StatefulWidget {
  final Map emprendimiento;

  ContactoTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  _ContactoTabState createState() => _ContactoTabState();
}

class _ContactoTabState extends State<ContactoTab> {
  late GoogleMapController mapController;
  // para arrancar la ubicacion del cliente
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar el marcador del emprendimiento desde el inicio.
    final latitud =
        double.tryParse('${widget.emprendimiento['contacto']['latitud']}');
    final longitud =
        double.tryParse('${widget.emprendimiento['contacto']['longitud']}');
    if (latitud != null && longitud != null) {
      markers.add(Marker(
        markerId: MarkerId("emprendimientoLocation"),
        position: LatLng(latitud, longitud),
      ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // obtener permiso ubicacion del cliente
  Future<void> _getUserLocation() async {
    // Verifica y solicita los permisos de ubicación.
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      // Los permisos están denegados, solicítalos.
      status = await Permission.locationWhenInUse.request();
      if (status.isDenied) {
        // Los permisos fueron denegados definitivamente.
        print('Permiso de ubicación denegado');
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      // Los permisos están denegados permanentemente, dirige al usuario a la configuración.
      openAppSettings();
      return;
    }

    // Asumiendo que ya has añadido el marcador del emprendimiento y del usuario a 'markers'
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });

    // Ubicación del emprendimiento.
    final LatLng emprendimientoLocation = LatLng(
        double.tryParse('${widget.emprendimiento['contacto']['latitud']}') ?? 0,
        double.tryParse('${widget.emprendimiento['contacto']['longitud']}') ??
            0);

    // Crear LatLngBounds
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(emprendimientoLocation.latitude, position.latitude),
        min(emprendimientoLocation.longitude, position.longitude),
      ),
      northeast: LatLng(
        max(emprendimientoLocation.latitude, position.latitude),
        max(emprendimientoLocation.longitude, position.longitude),
      ),
    );

    // Ajustar la cámara para mostrar ambos marcadores
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
  // fin obtener permiso ubicacion del cliente

  @override
  Widget build(BuildContext context) {
    final contacto = widget.emprendimiento['contacto'];
    final lat = contacto['latitud'];
    final lng = contacto['longitud'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lat != null && lng != null)
            Container(
              height: 250,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 16.0,
                ),
                markers: markers,
              ),
            ),
          ElevatedButton(
            onPressed: _getUserLocation,
            child: Text('Mostrar mi ubicación'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Dirección'),
            subtitle: Text(contacto['direccion'] ?? 'No disponible'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Teléfono'),
            subtitle: Text(contacto['telefono'] ?? 'No disponible'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Correo Electrónico'),
            subtitle: Text(contacto['correo'] ?? 'No disponible'),
          ),
          // Imágenes de contacto si existen
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Imágenes de contacto',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          ...?contacto['imagenesContacto']?.map((img) => Image.network(
                'http://192.168.100.6:8000${img['imagen']}',
                fit: BoxFit.cover,
              )),
        ],
      ),
    );
  }
}
