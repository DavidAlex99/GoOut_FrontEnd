import 'package:flutter/material.dart';

class SobreNosotrosTab extends StatelessWidget {
  final Map emprendimiento;

  SobreNosotrosTab({required this.emprendimiento});

  @override
  Widget build(BuildContext context) {
    var sobreNos = emprendimiento[
        'sobreNos']; // Asumimos que esta clave existe en el mapa.

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              sobreNos['descripcion'],
              style: TextStyle(fontSize: 16),
            ),
          ),
          ...sobreNos['imagenesSobreNos']
              .map((img) => Image.network(img['imagen']))
              .toList(),
        ],
      ),
    );
  }
}
