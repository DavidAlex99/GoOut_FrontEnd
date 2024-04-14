import 'package:flutter/material.dart';
import '../sobreNos/sobre_nosotros_tab.dart'; // Asegúrate de crear este archivo.
import '../comidas/menu_tab.dart'; // Asegúrate de crear este archivo.
import '../eventos/eventos_tab.dart'; // Asegúrate de crear este archivo.
import '../contacto/contacto_tab.dart'; // Asegúrate de crear este archivo.

class EmprendimientoDetallesPage extends StatefulWidget {
  final Map emprendimiento;

  EmprendimientoDetallesPage({Key? key, required this.emprendimiento})
      : super(key: key);

  @override
  _EmprendimientoDetallesPageState createState() =>
      _EmprendimientoDetallesPageState();
}

class _EmprendimientoDetallesPageState
    extends State<EmprendimientoDetallesPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Número de secciones
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.emprendimiento['nombre'] ?? 'Detalle del Emprendimiento'),
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
            SobreNosotrosTab(emprendimiento: widget.emprendimiento),
            MenuTab(emprendimiento: widget.emprendimiento),
            EventosTab(emprendimiento: widget.emprendimiento),
            // aqui se accede a la seccio de contacto
            ContactoTab(emprendimiento: widget.emprendimiento),
          ],
        ),
      ),
    );
  }
}
