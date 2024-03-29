import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ProfileService {
  static Future<http.Response> submitLogin(String username, String password) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/auth/login/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String> {
        'username': username,
        'password': password
      }),
    );
  }

  static Future<http.Response> submitRegister(String username, String email, String password1, String password2) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/auth/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String> {
        'username': username,
        'email': email,
        'password': password1,
        'confirmPassword': password2
      }),
    );
  }

  static Future<http.Response> submitResetPassword(String email) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/auth/reset-password-request/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String> {
        'email': email
      }),
    );
  }  

  static Future<http.Response> submitLogout(String token) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/auth/logout/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: null
    );
  }
}
