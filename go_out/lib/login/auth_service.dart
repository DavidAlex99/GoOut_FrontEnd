import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //final String baseUrl = 'http://127.0.0.1:8000/goOutApp';
  final String baseUrl = 'http://192.168.100.6:8000/goOutApp';

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
      try {
        final responseData = jsonDecode(response.body);
        final userId = responseData['user_id'] as int;
        String token = responseData['token'];
        print('token en login:');
        print(token);
        print('userId en login:');
        print(userId);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        await prefs.setString('token', token);
        return token;
      } catch (e) {
        print('Error parsing data from the login response: $e');
        print('Response body: ${response.body}');
        return null;
      }
    } else {
      print('Failed to log in: ${response.body}');
      return null;
    }
  }

  Future<String?> register(String username, String email, String first_name,
      String last_name, String password) async {
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
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final userId =
          responseData['user_id'] as int; // Asegúrate que es un entero
      String token = responseData['token'];
      print('Token en register:');
      print(token);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);
      await prefs.setString('token', token);
      return token;
    } else {
      print('Failed to register: ${response.body}');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      // Realizar la petición de cierre de sesión al servidor
      final response = await http.post(
        Uri.parse('$baseUrl/logoutCli/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );
      // Verificar la respuesta aquí si es necesario
    }
    // Eliminar el token del almacenamiento local independientemente de la respuesta del servidor
    await prefs.remove('token');
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? accessToken = googleAuth.accessToken;

        // Verifica que tienes un accessToken
        if (accessToken != null) {
          // Envía el token a tu servidor Django
          final response = await http.post(
            Uri.parse(
                'https://192.168.100.6:8000/google_login/'), // Cambia esto por tu URL correcta
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': accessToken}),
          );

          if (response.statusCode == 200) {
            // Aquí manejas la respuesta del servidor, por ejemplo, guardar el token del servidor
            final responseData = jsonDecode(response.body);
            final String token = responseData['token'];
            // Guarda el token del backend o cualquier otro dato necesario
            return token;
          } else {
            print('Failed to log in with Google: ${response.body}');
            return null;
          }
        }
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
    return null;
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    print("User signed out of Google account");
  }
}
