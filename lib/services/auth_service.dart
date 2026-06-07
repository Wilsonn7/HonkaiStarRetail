import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    String? firstName,
    String? lastName,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Koneksi gagal: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Koneksi gagal: $e',
      };
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Token tidak ditemukan',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        await clearToken();
        return {
          'success': false,
          'error': 'Token tidak valid',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Koneksi gagal: $e',
      };
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await clearToken();
      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Logout gagal: $e',
      };
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(String base64Image) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {'success': false, 'error': 'Unauthorized'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/upload-avatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'avatar': base64Image,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Upload avatar timeout'),
      );

      // Check if response is JSON
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'],
            'user': User.fromJson(data['user']),
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server response error: $e',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'error': errorData['error'] ?? 'Upload avatar gagal (Status: ${response.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: Status ${response.statusCode}',
          };
        }
      }
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Upload timeout - file terlalu besar atau koneksi lambat',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Koneksi gagal: $e',
      };
    }
  }

  Future<Map<String, dynamic>> loginWithOAuth({
    required String provider,
  }) async {
    try {
      // Provider: 'google', 'facebook', 'twitter'
      final oauthUrl = '$baseUrl/auth/$provider';
      
      // Buka browser untuk OAuth login
      // Nanti akan di-handle oleh webview di OAuth screen
      return {
        'success': true,
        'oauthUrl': oauthUrl,
        'provider': provider,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'OAuth login gagal: $e',
      };
    }
  }

  // Handle OAuth callback token
  Future<Map<String, dynamic>> handleOAuthCallback({
    required String token,
    required String provider,
  }) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'error': 'Token tidak diterima dari $provider',
        };
      }

      // Simpan token
      await saveToken(token);

      // Verify token dengan backend
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Login dengan $provider berhasil',
          'user': User.fromJson(data['user']),
        };
      } else {
        await clearToken();
        return {
          'success': false,
          'error': 'Token tidak valid',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Koneksi gagal: $e',
      };
    }
  }
}

