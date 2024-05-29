import 'package:flutter/material.dart';
import 'comida_detalles.dart'; // Asegúrate de crear este archivo

class MenuTab extends StatelessWidget {
  final Map emprendimiento;

  MenuTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> comidas = emprendimiento['comidas'] ?? [];

    // Verifica si la lista está vacía
    if (comidas.isEmpty) {
      return Center(
        child: Text(
          'No hay información disponible en la sección Menú.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: comidas.length,
      itemBuilder: (context, index) {
        var comida = comidas[index];
        return Card(
          child: ListTile(
            title: Text(comida['nombre']),
            subtitle: Text(comida['descripcion']),
            leading: comida['imagen'] != null
                ? Image.network(
                    comida['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : SizedBox(
                    width: 100, height: 100), // Un placeholder o espacio vacío
            trailing: IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                // Navegar a la nueva página de detalles
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ComidaDetallesPage(comida: comida),
                ));
              },
            ),
          ),
        );
      },
    );
  }
}
