import 'package:flutter/material.dart';
import '../sobreNos/sobre_nosotros_tab.dart'; // Asegúrate de crear este archivo.
import '../comidas/menu_tab.dart'; // Asegúrate de crear este archivo.
import '../eventos/eventos_tab.dart'; // Asegúrate de crear este archivo.
import '../contacto/contacto_tab.dart'; // Asegúrate de crear este archivo.

class EmprendimientoDetallesPage extends StatelessWidget {
  final Map emprendimiento;

  EmprendimientoDetallesPage({required this.emprendimiento});

  @override
  Widget build(BuildContext context) {
    print(
        "Emprendimiento en EmprendimientoDetallesPage: ${emprendimiento.toString()}");
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(emprendimiento['nombre']),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Sobre Nosotros'),
              Tab(text: 'Menú'),
              Tab(text: 'Eventos'),
              Tab(text: 'Contacto'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SobreNosotrosTab(emprendimiento: emprendimiento),
            MenuTab(emprendimiento: emprendimiento),
            EventosTab(emprendimiento: emprendimiento),
            ContactoTab(emprendimiento: emprendimiento),
          ],
        ),
      ),
    );
  }
}
