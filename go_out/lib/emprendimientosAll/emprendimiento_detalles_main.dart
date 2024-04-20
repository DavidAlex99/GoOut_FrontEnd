import 'package:flutter/material.dart';
import '../sobreNos/sobre_nosotros_tab.dart';
import '../comidas/menu_tab.dart';
import '../eventos/eventos_tab.dart';
import '../contacto/contacto_tab.dart';
import '../buzonQueja/quejas_tab.dart';
import '../resenas/resenas_tab.dart';
import '../login/auth_service.dart';
import '../login/login_page.dart';

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
  void _logout() async {
    await AuthService().logout(); // Llama al método de cerrar sesión
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Redirige al LoginPage
    );
  }

  void _openQuejasTab() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            QuejasTab(emprendimiento: widget.emprendimiento)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Número de secciones
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.emprendimiento['nombre'] ?? 'Detalle del Emprendimiento'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.report_problem),
              onPressed: _openQuejasTab,
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Sobre Nosotros'),
              Tab(text: 'Menú'),
              Tab(text: 'Eventos'),
              Tab(text: 'Contacto'),
              Tab(text: 'Deja tu opinión'),
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
          ],
        ),
      ),
    );
  }
}
