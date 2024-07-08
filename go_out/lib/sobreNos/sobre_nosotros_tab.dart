import 'package:flutter/material.dart';

class SobreNosotrosTab extends StatelessWidget {
  final Map emprendimiento;

  SobreNosotrosTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map sobreNos = emprendimiento['sobreNos'] ?? {};
    List<dynamic> imagenesSobreNos = sobreNos['imagenesSobreNos'] ?? [];
    print("imagees de sobrenosotros");
    print(imagenesSobreNos);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre Nosotros',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 16.0),
            Text(
              sobreNos['descripcion'] ?? 'No hay descripción disponible.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 20.0),
            Text(
              'Galería',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 10.0),
            if (imagenesSobreNos.isEmpty)
              Text(
                'No hay imágenes disponibles en la galería.',
                style: Theme.of(context).textTheme.headlineLarge,
              )
            else
              ...imagenesSobreNos.map((imagen) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(
                    'http://192.168.100.6:8000${imagen['imagen']}',

                    /*
                    'http://127.0.0.1:8000${imagen['imagen']}',
                    */
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
