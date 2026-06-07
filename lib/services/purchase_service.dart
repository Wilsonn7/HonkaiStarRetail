import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/purchase.dart';
import '../models/user.dart';

class PurchaseService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> createPurchase({
    required int resourceId,
    required int quantity,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Unauthorized',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/purchases'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'resourceId': resourceId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'purchaseId': data['purchaseId'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Gagal melakukan pembelian',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Koneksi gagal: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getPurchaseHistory() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Unauthorized',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/purchases/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final purchases = data.map((json) => Purchase.fromJson(json)).toList();
        return {
          'success': true,
          'purchases': purchases,
        };
      } else {
        return {
          'success': false,
          'error': 'Gagal mengambil riwayat pembelian',
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

class UserService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Unauthorized',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': User.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'error': 'Gagal mengambil profil user',
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
