import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service để lấy thông tin điện thoại từ API
class PhoneInfoService {
  // API endpoints - có thể thay đổi theo backend của bạn
  static const String _baseUrl =
      'https://api.example.com'; // Thay bằng URL thực

  /// Chuyển đổi model name sang marketing name
  /// Ví dụ: "SM-G991N" -> "Samsung Galaxy S21 5G"
  static Future<String?> getMarketingName(
    String modelName,
    String brand,
  ) async {
    try {
      // Option 1: Gọi API của bạn
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/api/phone/marketing-name?model=$modelName&brand=$brand',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['marketingName'] as String?;
      }
    } catch (e) {
      debugPrint('Error getting marketing name from API: $e');
    }

    // Option 2: Fallback - Tên chuẩn từ brand & model
    if (brand.isNotEmpty && !modelName.toLowerCase().contains(brand.toLowerCase())) {
      return '$brand $modelName';
    }
    return modelName;
  }

  /// Lấy URL hình ảnh điện thoại
  static Future<String?> getPhoneImageUrl(
    String modelName,
    String brand,
  ) async {
    try {
      // Option 1: Gọi API của bạn
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/api/phone/image?model=$modelName&brand=$brand',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['imageUrl'] as String?;
      }
    } catch (e) {
      debugPrint('Error getting phone image from API: $e');
    }

    // Option 2: Fallback - Dùng GSMArena hoặc CDN
    return _getGSMArenaImageUrl(modelName, brand);
  }

  /// Lấy hình ảnh từ GSMArena
  static String _getGSMArenaImageUrl(String modelName, String brand) {
    // GSMArena image pattern
    final searchQuery = Uri.encodeComponent('$brand $modelName');
    return 'https://fdn2.gsmarena.com/vv/bigpic/$searchQuery.jpg';
  }

  /// Lấy thông tin đầy đủ về điện thoại
  static Future<PhoneInfo?> getPhoneInfo(String modelName, String brand) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/phone/info?model=$modelName&brand=$brand'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PhoneInfo.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error getting phone info from API: $e');
    }

    return null;
  }

  /// Search điện thoại theo marketing name
  static Future<List<PhoneSearchResult>> searchPhone(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/api/phone/search?q=${Uri.encodeComponent(query)}',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => PhoneSearchResult.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error searching phone: $e');
    }

    return [];
  }
}

/// Model cho thông tin điện thoại
class PhoneInfo {
  final String modelName;
  final String marketingName;
  final String brand;
  final String? imageUrl;
  final String? releaseDate;
  final Map<String, dynamic>? specs;

  PhoneInfo({
    required this.modelName,
    required this.marketingName,
    required this.brand,
    this.imageUrl,
    this.releaseDate,
    this.specs,
  });

  factory PhoneInfo.fromJson(Map<String, dynamic> json) {
    return PhoneInfo(
      modelName: json['modelName'] as String,
      marketingName: json['marketingName'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String?,
      releaseDate: json['releaseDate'] as String?,
      specs: json['specs'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'marketingName': marketingName,
      'brand': brand,
      'imageUrl': imageUrl,
      'releaseDate': releaseDate,
      'specs': specs,
    };
  }
}

/// Model cho kết quả search
class PhoneSearchResult {
  final String modelName;
  final String marketingName;
  final String brand;
  final String? thumbnailUrl;

  PhoneSearchResult({
    required this.modelName,
    required this.marketingName,
    required this.brand,
    this.thumbnailUrl,
  });

  factory PhoneSearchResult.fromJson(Map<String, dynamic> json) {
    return PhoneSearchResult(
      modelName: json['modelName'] as String,
      marketingName: json['marketingName'] as String,
      brand: json['brand'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}
