import 'package:flutter/material.dart';

class MenuTab extends StatelessWidget {
  final Map emprendimiento;

  MenuTab({required this.emprendimiento});

  @override
  Widget build(BuildContext context) {
    // Asumimos que "comidas" es una lista de elementos del menú que está en el emprendimiento Map
    List comidas = emprendimiento['comidas'] ?? [];

    return ListView.builder(
      itemCount: comidas.length,
      itemBuilder: (context, index) {
        var comida = comidas[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: comida['imagen'] != null
                ? Image.network(
                    comida['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : null,
            title: Text(comida['nombre']),
            subtitle: Text('${comida['descripcion']} - \$${comida['precio']}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
