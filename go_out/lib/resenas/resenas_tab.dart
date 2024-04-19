import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'resena_form.dart'; // Asegúrate de que este import refleja la ubicación correcta de tu archivo del formulario de reseñas.

class ResenasTab extends StatefulWidget {
  final Map emprendimiento;

  ResenasTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  _ResenasTabState createState() => _ResenasTabState();
}

class _ResenasTabState extends State<ResenasTab> {
  List _resenas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResenas();
  }

  Future<void> _fetchResenas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('Authentication token is not available.');
      }

      final response = await http.get(
        Uri.parse(
            "http://192.168.100.6:8000/goOutApp/emprendimientos/${widget.emprendimiento['id']}/reseñas/"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _resenas = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load reviews. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las reseñas: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas de ${widget.emprendimiento['nombre']}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchResenas,
              child: _resenas.isEmpty
                  ? ListView(
                      children: [Center(child: Text("No hay reseñas aún"))])
                  : ListView.builder(
                      itemCount: _resenas.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_resenas[index]['usuario_username']),
                            subtitle: Text(_resenas[index]['comentario']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                Text("${_resenas[index]['calificacion']} / 5"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(),
        child: Icon(Icons.add),
        tooltip: 'Añadir Reseña',
      ),
    );
  }

  void _navigateAndRefresh() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResenaFormPage(emprendimientoId: widget.emprendimiento['id']),
      ),
    ).then((_) =>
        _fetchResenas()); // Refrescar las reseñas después de regresar del formulario
  }
}
