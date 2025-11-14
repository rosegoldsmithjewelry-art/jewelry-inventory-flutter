import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ItemService {
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get cloudinaryUrl => dotenv.env['CLOUDINARY_UPLOAD_URL'] ?? '';
  static String get cloudinaryPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  static Future<List> getItems() async {
    try {
      final res = await http.get(Uri.parse(apiUrl));
      debugPrint('Get items response status: ${res.statusCode}');
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('Get items error: $e');
    }
    return [];
  }

  static Future<void> addItem(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(apiUrl),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(data),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to add item: ${res.body}');
    }
  }

  static Future<void> updateItem(String itemCode, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$apiUrl/$itemCode'),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update item: ${res.body}');
    }
  }

  static Future<void> deleteItem(String itemCode) async {
    final res = await http.delete(Uri.parse('$apiUrl/$itemCode'));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete item: ${res.body}');
    }
  }

  static Future<String?> uploadImage(File file) async {
    try {
      final dioClient = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': cloudinaryPreset,
      });
      debugPrint('Uploading to: $cloudinaryUrl with preset: $cloudinaryPreset');
      final response = await dioClient.post(cloudinaryUrl, data: formData);
      debugPrint('Upload response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('Upload success: ${response.data['secure_url']}');
        return response.data['secure_url'];
      } else {
        debugPrint('Upload failed: ${response.data}');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
    return null;
  }

  static String get salesUrl {
    // If apiUrl points to items endpoint, replace items with sales, else append /sales
    if (apiUrl.endsWith('/items')) return apiUrl.replaceAll('/items', '/sales');
    if (apiUrl.endsWith('/items/')) return apiUrl.replaceAll('/items/', '/sales/');
    return apiUrl.endsWith('/') ? '${apiUrl}sales' : '$apiUrl/sales';
  }

  static Future<void> recordSale(Map<String, dynamic> saleData) async {
    final res = await http.post(
      Uri.parse(salesUrl),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(saleData),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to record sale: ${res.body}');
    }
  }

  static Future<List> getSales() async {
    try {
      final res = await http.get(Uri.parse(salesUrl));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint('Get sales error: $e');
    }
    return [];
  }
}
