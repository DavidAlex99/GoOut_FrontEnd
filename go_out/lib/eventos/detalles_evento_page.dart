import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/auth_service.dart';
import '../login/login_page.dart';

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

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _reservarPlazas() async {
    if (_cantidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Por favor, ingresa la cantidad de plazas a reservar.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('Authentication token is not available.');
      }

      final response = await http.post(
        Uri.parse("https://chillx.onrender.com/goOutApp/reservas/crear/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'evento': widget.evento['id'],
          'cantidad': int.tryParse(_cantidadController.text),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva realizada con éxito')),
        );
      } else {
        throw Exception(
            'Failed to make a reservation. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al realizar la reserva: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await AuthService().logout(); // Solo llama al método de cerrar sesión
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Redirige al LoginPage
    );
  }

  @override
  Widget build(BuildContext context) {
    List imagenesEvento = widget.evento['imagenesEvento'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.evento['titulo']), actions: [
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: _logout,
        ),
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imagenesEvento.isNotEmpty)
                Image.network(
                  imagenesEvento[0]['imagen'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  widget.evento['descripcion'],
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
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
