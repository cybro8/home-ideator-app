import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_state.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8002';
    }
    return 'http://127.0.0.1:8002';
  }

  // Standard header builder
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthState.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- Auth Endpoints ---

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/auth/login';
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await AuthState.saveToken(data['access_token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = '$baseUrl/auth/register';
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  // --- Device Endpoints ---

  static Future<List<dynamic>> getMyDevices() async {
    final url = '$baseUrl/my/devices';
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await AuthState.clearToken();
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load devices');
    }
  }

  static Future<List<dynamic>> getDeviceData(String deviceId, {int limit = 1}) async {
    final url = '$baseUrl/my/devices/$deviceId/data?limit=$limit';
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load device data');
    }
  }

  // --- Shop Endpoints ---

  static Future<List<dynamic>> getProducts() async {
    final url = '$baseUrl/shop/products';
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}
