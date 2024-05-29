import 'package:flutter/material.dart';

class SobreNosotrosTab extends StatelessWidget {
  final Map emprendimiento;

  SobreNosotrosTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map sobreNos = emprendimiento['sobreNos'] ?? {};
    List<dynamic> imagenesSobreNos = sobreNos['imagenesSobreNos'] ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre Nosotros',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 16.0),
            Text(
              sobreNos['descripcion'] ?? 'No hay descripción disponible.',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 20.0),
            Text(
              'Galería',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10.0),
            if (imagenesSobreNos.isEmpty)
              Text(
                'No hay imágenes disponibles en la galería.',
                style: Theme.of(context).textTheme.bodyText2,
              )
            else
              ...imagenesSobreNos.map((imagen) {
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
      ),
    );
  }
}
