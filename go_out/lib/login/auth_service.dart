import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://chillx.onrender.com/goOutApp';
  //final String baseUrl = 'http://172.19.61.234:8000/goOutApp';

  // Método para guardar el token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('Token saved: $token'); // Imprime el token para verificar
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/loginCli/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String token = responseData['token'];
      print('token en login:');
      print(token);
      await _saveToken(token); // Guardar el token
      return token;
    } else {
      return null;
    }
  }

  Future<String?> register(String username, String email, String first_name,
      String last_name, String password, String telefono) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registroCli/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'first_name': first_name,
        'last_name': last_name,
        'password': password,
        'telefono': telefono,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      String token = responseData['token'];
      print('token en register:');
      print(token);
      await _saveToken(token); // Guardar el token
      return token;
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      // Realizar la petición de cierre de sesión al servidor
      final response = await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );
      // Verificar la respuesta aquí si es necesario
    }
    // Eliminar el token del almacenamiento local independientemente de la respuesta del servidor
    await prefs.remove('token');
  }
}
