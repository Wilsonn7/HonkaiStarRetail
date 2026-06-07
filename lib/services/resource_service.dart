import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resource.dart';

class ResourceService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> getResources({String? type}) async {
    try {
      String url = '$baseUrl/resources';
      if (type != null && type.isNotEmpty) {
        url += '?type=$type';
      }

      final token = await _getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('GET $url');
      final response = await http.get(Uri.parse(url), headers: headers);
      print('GET /resources status: ${response.statusCode}');
      print('GET /resources body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resources = data.map((json) => Resource.fromJson(json)).toList();
        return {'success': true, 'resources': resources};
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : null;
        return {
          'success': false,
          'error': errorBody != null && errorBody['error'] != null
              ? errorBody['error']
              : 'Gagal mengambil resources',
        };
      }
    } catch (e) {
      print('GET /resources exception: $e');
      return {'success': false, 'error': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> getResourceDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/resources/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'resource': Resource.fromJson(data)};
      } else {
        return {'success': false, 'error': 'Resource tidak ditemukan'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> createResource({
    required String name,
    required String type,
    required String description,
    required int stock,
    required String imageUrl,
    required double price,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'error': 'Unauthorized'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/resources'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'type': type,
          'description': description,
          'stock': stock,
          'imageUrl': imageUrl,
          'price': price,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Hanya admin yang dapat menambah resource',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Gagal menambah resource',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> updateResource({
    required int id,
    required String name,
    required String type,
    required String description,
    required int stock,
    required String imageUrl,
    required double price,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'error': 'Unauthorized'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/resources/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'type': type,
          'description': description,
          'stock': stock,
          'imageUrl': imageUrl,
          'price': price,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Hanya admin yang dapat mengubah resource',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Gagal mengubah resource',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteResource(int id) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'error': 'Unauthorized'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/resources/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Hanya admin yang dapat menghapus resource',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Gagal menghapus resource',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Koneksi gagal: $e'};
    }
  }
}
