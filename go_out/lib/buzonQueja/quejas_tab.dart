import 'package:flutter/material.dart';
import './quejas_form.dart';

class QuejasTab extends StatelessWidget {
  final Map emprendimiento;

  QuejasTab({Key? key, required this.emprendimiento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Reportar un problema'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QuejaFormPage(emprendimientoId: emprendimiento['id']),
            ),
          );
        },
      ),
    );
  }
}
