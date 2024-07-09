import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '/src/utils/app_const.dart';
// This service class abstracts server calls required for auth views.
// These static method only returns the request, and any error must
// be handled by the caller.
class ProfileService {
  static Future<http.Response> submitLogin(
    String username,
    String password,
  ) async {
    return await http.post(
      Uri.parse('${AppConst.baseURL}/auth/login/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'username': username,
        'password': password,
      }),
    );
  }

  static Future<http.Response> submitRegister(
    String username,
    String email,
    String password1,
    String password2,
  ) async {
    return await http.post(
      Uri.parse('${AppConst.baseURL}/auth/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'username': username,
        'email': email,
        'password': password1,
        'confirmPassword': password2,
      }),
    );
  }

  static Future<http.Response> submitResetPassword(
    String email,
  ) async {
    return await http.post(
      Uri.parse('${AppConst.baseURL}/auth/reset-password-request/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'email': email,
      }),
    );
  }

  static Future<http.Response> submitLogout(
    String token,
  ) async {
    return await http.post(
      Uri.parse('${AppConst.baseURL}/auth/logout/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: null
    );
  }

  static Future<http.Response> getUserInfo(
    String token,
  ) async {
    return await http.get(
      Uri.parse('${AppConst.baseURL}/api/user/me/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      }
    );
  }

  static Future<http.Response> submitProfilePicture(
    String token,
    int userId,
    String base64Image,
  ) async {
    return await http.patch(
      Uri.parse('${AppConst.baseURL}/api/user/$userId/profile-picture/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'profile_picture': base64Image,
      }),
    );
  }
}
