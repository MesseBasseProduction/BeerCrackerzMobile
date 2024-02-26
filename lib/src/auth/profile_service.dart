import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ProfileService {
  static Future<http.Response> submitLogin(String username, String password) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/auth/login/'),
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
      Uri.parse('https://beercrackerz.org/api/auth/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String> {
        'username': username,
        'email': email,
        'password1': password1,
        'password2': password2
      }),
    );
  }

  static Future<http.Response> submitResetPassword(String email) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/auth/password-reset-request/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String> {
        'email': email
      }),
    );
  }  

  static Future<http.Response> submitLogout(String sessionCookie) async {
    String csrf = '';
    var splitted = sessionCookie.split(';');
    for (var element in splitted) {
      var cookie = element.split('=');
      if (cookie[0].toLowerCase().contains('srf')) {
        csrf = cookie[1];
      }
    }

    final response = await http.post(
      Uri.parse('https://beercrackerz.org/api/auth/logout/'),
      headers: <String, String>{
        'content-type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'accept-encoding': 'gzip, deflate, br',
        'x-csrftoken': csrf,
        'host': 'beercrackerz.org',
        'referer': 'https://beercrackerz.org',
        'origin': 'https://beercrackerz.org'
      },
      body: null,
    );
    if (response.statusCode == 200) {
      String source = const Utf8Decoder().convert(response.bodyBytes);
      return jsonDecode(source);
    } else {
      throw Exception('HTTP call failed : https://beercrackerz.org/api/auth/logout/ returned ${response.statusCode} - ${response.body}');
    }
  }
}
