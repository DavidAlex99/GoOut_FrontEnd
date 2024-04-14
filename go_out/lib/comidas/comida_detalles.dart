import 'package:flutter/material.dart';

class ComidaDetallesPage extends StatelessWidget {
  final Map comida;

  ComidaDetallesPage({Key? key, required this.comida}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aquí podrías agregar más campos si están disponibles en el mapa de comida
    return Scaffold(
      appBar: AppBar(
        title: Text(comida['nombre']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            comida['imagen'] != null
                ? Image.network(
                    'http://192.168.100.6:8000${comida['imagen']}',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : SizedBox(height: 300), // Un placeholder o espacio vacío
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                comida['descripcion'],
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            // Puedes añadir más Widgets aquí para mostrar toda la información que quieras
          ],
        ),
      ),
    );
  }
}
