import 'package:flutter/material.dart';
import '../sobreNos/sobre_nosotros_tab.dart';
import '../comidas/menu_tab.dart';
import '../eventos/eventos_tab.dart';
import '../contacto/contacto_tab.dart';
import '../buzonQueja/quejas_tab.dart';
import '../resenas/resenas_tab.dart';

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
      length: 6, // Número de secciones
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
              Tab(text: 'Deja tu opinión'),
              Tab(icon: Icon(Icons.report_problem)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SobreNosotrosTab(emprendimiento: widget.emprendimiento),
            MenuTab(emprendimiento: widget.emprendimiento),
            EventosTab(emprendimiento: widget.emprendimiento),
            ContactoTab(emprendimiento: widget.emprendimiento),
            ResenasTab(emprendimiento: widget.emprendimiento),
            QuejasTab(emprendimiento: widget.emprendimiento),
          ],
        ),
      ),
    );
  }
}
