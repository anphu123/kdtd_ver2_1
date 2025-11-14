import 'dart:convert';
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
      print('Error getting marketing name from API: $e');
    }

    // Option 2: Fallback - Dùng local mapping
    return _getLocalMarketingName(modelName, brand);
  }

  /// Local mapping cho các model phổ biến
  static String _getLocalMarketingName(String modelName, String brand) {
    final model = modelName.toUpperCase();
    final brandLower = brand.toLowerCase();

    // Samsung
    if (brandLower.contains('samsung')) {
      if (model.contains('SM-S921')) return 'Samsung Galaxy S24';
      if (model.contains('SM-S911')) return 'Samsung Galaxy S23';
      if (model.contains('SM-S901')) return 'Samsung Galaxy S22';
      if (model.contains('SM-G991')) return 'Samsung Galaxy S21 5G';
      if (model.contains('SM-G981')) return 'Samsung Galaxy S20 5G';
      if (model.contains('SM-A546')) return 'Samsung Galaxy A54 5G';
      if (model.contains('SM-A346')) return 'Samsung Galaxy A34 5G';
      if (model.contains('SM-F936')) return 'Samsung Galaxy Z Fold4';
      if (model.contains('SM-F721')) return 'Samsung Galaxy Z Flip4';
    }

    // iPhone
    if (brandLower.contains('apple') || model.contains('IPHONE')) {
      if (model.contains('IPHONE16')) return 'iPhone 16';
      if (model.contains('IPHONE15')) return 'iPhone 15';
      if (model.contains('IPHONE14')) return 'iPhone 14';
      if (model.contains('IPHONE13')) return 'iPhone 13';
      if (model.contains('IPHONE12')) return 'iPhone 12';
      if (model.contains('PRO MAX')) return '$model Pro Max';
      if (model.contains('PRO')) return '$model Pro';
    }

    // Xiaomi
    if (brandLower.contains('xiaomi')) {
      if (model.contains('2312')) return 'Xiaomi 14';
      if (model.contains('2211')) return 'Xiaomi 13';
      if (model.contains('2201')) return 'Xiaomi 12';
    }

    // Fallback: return model name
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
      print('Error getting phone image from API: $e');
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
      print('Error getting phone info from API: $e');
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
      print('Error searching phone: $e');
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
