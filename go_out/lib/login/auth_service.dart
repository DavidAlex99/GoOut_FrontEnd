import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      'http://192.168.100.6:8000/goOutApp'; // Reemplaza esto por la URL real de tu backend

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/login/'), // Asegúrate de que esta ruta coincide con tu backend
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Asumiendo que tu API devuelve el ID del usuario en la respuesta
      final responseData = jsonDecode(response.body);
      return responseData[
          'user_id']; // Asegúrate de que este campo coincide con la respuesta de tu API
    } else {
      // Manejar error o retorno nulo si falla el inicio de sesión
      return null;
    }
  }

  Future<String?> register(
      String username, String email, String password, String telefono) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
        'telefono': telefono, // Incluir el campo adicional
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['user_id']
          .toString(); // Devolver el user_id para uso futuro
    } else {
      return null;
    }
  }
}
