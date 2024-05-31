import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormularioContactoPage extends StatefulWidget {
  @override
  _FormularioContactoPageState createState() => _FormularioContactoPageState();
}

class _FormularioContactoPageState extends State<FormularioContactoPage> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _mensajeController = TextEditingController();

  Future<void> _enviarMensaje() async {
    final nombre = _nombreController.text;
    final email = _emailController.text;
    final mensaje = _mensajeController.text;

    // Llama a tu API para enviar el mensaje al emprendimiento
    final response = await http.post(
      Uri.parse(
          'http://192.168.100.6:8000/goOutApp/emprendimientos/<int:pk_emprendimiento>/formulario_contacto/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'mensaje': mensaje,
      }),
    );

    // Verifica el estado de la respuesta y muestra un mensaje al usuario
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensaje enviado correctamente')),
      );
      // Limpia los campos después de enviar
      _nombreController.clear();
      _emailController.clear();
      _mensajeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el mensaje')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulario de Contacto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: _mensajeController,
              decoration: InputDecoration(labelText: 'Mensaje'),
              maxLines: 5,
            ),
            ElevatedButton(
              onPressed: _enviarMensaje,
              child: Text('Enviar Mensaje'),
            ),
          ],
        ),
      ),
    );
  }
}
