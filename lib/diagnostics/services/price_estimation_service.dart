import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service để ước tính giá thu mua điện thoại
class PriceEstimationService {
  static const String _baseUrl =
      'https://api.example.com'; // Thay bằng URL thực

  /// Ước tính giá thu mua dựa trên điểm số và thông tin thiết bị
  static Future<PriceEstimate?> estimatePrice({
    required String modelName,
    required String brand,
    required int score,
    required int ramGb,
    required int romGb,
    required String origin,
  }) async {
    try {
      // Gọi API để lấy giá
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/price/estimate'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'modelName': modelName,
              'brand': brand,
              'score': score,
              'ramGb': ramGb,
              'romGb': romGb,
              'origin': origin,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PriceEstimate.fromJson(data);
      }
    } catch (e) {
      print('Error estimating price from API: $e');
    }

    // Fallback: Tính giá local
    return _calculateLocalPrice(
      modelName: modelName,
      brand: brand,
      score: score,
      ramGb: ramGb,
      romGb: romGb,
      origin: origin,
    );
  }

  /// Tính giá local dựa trên logic
  static PriceEstimate _calculateLocalPrice({
    required String modelName,
    required String brand,
    required int score,
    required int ramGb,
    required int romGb,
    required String origin,
  }) {
    // Giá cơ bản theo hãng và model
    double basePrice = _getBasePrice(modelName, brand);

    // Điều chỉnh theo RAM/ROM
    basePrice += (ramGb - 4) * 200000; // +200k mỗi GB RAM
    basePrice += (romGb - 64) / 64 * 500000; // +500k mỗi 64GB ROM

    // Điều chỉnh theo điểm số (score)
    double scoreMultiplier = score / 100.0;

    // Giảm giá theo độ hao mòn
    if (score >= 90) {
      scoreMultiplier = 1.0; // 100% giá
    } else if (score >= 80) {
      scoreMultiplier = 0.85; // 85% giá
    } else if (score >= 70) {
      scoreMultiplier = 0.70; // 70% giá
    } else if (score >= 60) {
      scoreMultiplier = 0.55; // 55% giá
    } else {
      scoreMultiplier = 0.40; // 40% giá
    }

    // Điều chỉnh theo xuất xứ
    double originMultiplier = 1.0;
    if (origin.toLowerCase().contains('trung quốc')) {
      originMultiplier = 0.9; // -10%
    } else if (origin.toLowerCase().contains('việt nam')) {
      originMultiplier = 0.95; // -5%
    }

    final estimatedPrice = basePrice * scoreMultiplier * originMultiplier;
    final minPrice = estimatedPrice * 0.9; // -10%
    final maxPrice = estimatedPrice * 1.1; // +10%

    return PriceEstimate(
      minPrice: minPrice.round(),
      maxPrice: maxPrice.round(),
      estimatedPrice: estimatedPrice.round(),
      currency: 'VND',
      confidence: _calculateConfidence(score),
      factors: _getPriceFactors(score, origin),
      recommendation: _getRecommendation(score, estimatedPrice),
    );
  }

  /// Lấy giá cơ bản theo model
  static double _getBasePrice(String modelName, String brand) {
    final model = modelName.toUpperCase();
    final brandLower = brand.toLowerCase();

    // Samsung
    if (brandLower.contains('samsung')) {
      if (model.contains('S24')) return 20000000;
      if (model.contains('S23')) return 15000000;
      if (model.contains('S22')) return 12000000;
      if (model.contains('S21')) return 10000000;
      if (model.contains('S20')) return 8000000;
      if (model.contains('A54')) return 7000000;
      if (model.contains('A34')) return 5000000;
      if (model.contains('FOLD')) return 25000000;
      if (model.contains('FLIP')) return 15000000;
      return 5000000; // Default Samsung
    }

    // iPhone
    if (brandLower.contains('apple') || model.contains('IPHONE')) {
      if (model.contains('15')) return 25000000;
      if (model.contains('14')) return 20000000;
      if (model.contains('13')) return 15000000;
      if (model.contains('12')) return 12000000;
      if (model.contains('11')) return 10000000;
      if (model.contains('PRO MAX')) return 30000000;
      return 15000000; // Default iPhone
    }

    // Xiaomi
    if (brandLower.contains('xiaomi')) {
      if (model.contains('14')) return 12000000;
      if (model.contains('13')) return 10000000;
      if (model.contains('12')) return 8000000;
      return 5000000; // Default Xiaomi
    }

    // Oppo
    if (brandLower.contains('oppo')) {
      if (model.contains('FIND')) return 10000000;
      if (model.contains('RENO')) return 7000000;
      return 4000000; // Default Oppo
    }

    // Default
    return 3000000;
  }

  /// Tính độ tin cậy của ước tính
  static double _calculateConfidence(int score) {
    if (score >= 90) return 0.95;
    if (score >= 80) return 0.90;
    if (score >= 70) return 0.85;
    if (score >= 60) return 0.75;
    return 0.60;
  }

  /// Lấy các yếu tố ảnh hưởng giá
  static List<PriceFactor> _getPriceFactors(int score, String origin) {
    final factors = <PriceFactor>[];

    // Điểm số
    if (score >= 90) {
      factors.add(
        PriceFactor(
          name: 'Tình trạng xuất sắc',
          impact: 'positive',
          description: 'Máy như mới, giá cao',
        ),
      );
    } else if (score >= 80) {
      factors.add(
        PriceFactor(
          name: 'Tình trạng tốt',
          impact: 'neutral',
          description: 'Giảm 15% so với mới',
        ),
      );
    } else if (score >= 70) {
      factors.add(
        PriceFactor(
          name: 'Tình trạng khá',
          impact: 'negative',
          description: 'Giảm 30% so với mới',
        ),
      );
    } else {
      factors.add(
        PriceFactor(
          name: 'Tình trạng yếu',
          impact: 'negative',
          description: 'Giảm 45-60% so với mới',
        ),
      );
    }

    // Xuất xứ
    if (origin.toLowerCase().contains('trung quốc')) {
      factors.add(
        PriceFactor(
          name: 'Xuất xứ Trung Quốc',
          impact: 'negative',
          description: 'Giảm 10% giá',
        ),
      );
    }

    return factors;
  }

  /// Lấy khuyến nghị
  static String _getRecommendation(int score, double price) {
    if (score >= 90) {
      return 'Máy trong tình trạng xuất sắc. Nên bán với giá cao.';
    } else if (score >= 80) {
      return 'Máy còn tốt. Giá thu mua hợp lý.';
    } else if (score >= 70) {
      return 'Máy có một số vấn đề nhỏ. Cân nhắc sửa chữa trước khi bán.';
    } else if (score >= 60) {
      return 'Máy có nhiều vấn đề. Nên sửa chữa để tăng giá.';
    } else {
      return 'Máy cần sửa chữa nhiều. Giá thu mua thấp.';
    }
  }
}

/// Model cho ước tính giá
class PriceEstimate {
  final int minPrice;
  final int maxPrice;
  final int estimatedPrice;
  final String currency;
  final double confidence; // 0.0 - 1.0
  final List<PriceFactor> factors;
  final String recommendation;

  PriceEstimate({
    required this.minPrice,
    required this.maxPrice,
    required this.estimatedPrice,
    required this.currency,
    required this.confidence,
    required this.factors,
    required this.recommendation,
  });

  factory PriceEstimate.fromJson(Map<String, dynamic> json) {
    return PriceEstimate(
      minPrice: json['minPrice'] as int,
      maxPrice: json['maxPrice'] as int,
      estimatedPrice: json['estimatedPrice'] as int,
      currency: json['currency'] as String? ?? 'VND',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      factors:
          (json['factors'] as List?)
              ?.map((f) => PriceFactor.fromJson(f))
              .toList() ??
          [],
      recommendation: json['recommendation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'estimatedPrice': estimatedPrice,
      'currency': currency,
      'confidence': confidence,
      'factors': factors.map((f) => f.toJson()).toList(),
      'recommendation': recommendation,
    };
  }

  String get formattedEstimatedPrice => _formatPrice(estimatedPrice);
  String get formattedMinPrice => _formatPrice(minPrice);
  String get formattedMaxPrice => _formatPrice(maxPrice);
  String get priceRange => '$formattedMinPrice - $formattedMaxPrice';

  String _formatPrice(int price) {
    if (currency == 'VND') {
      // Format: 10.000.000 đ
      return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
    }
    return '$price $currency';
  }
}

/// Yếu tố ảnh hưởng giá
class PriceFactor {
  final String name;
  final String impact; // 'positive', 'negative', 'neutral'
  final String description;

  PriceFactor({
    required this.name,
    required this.impact,
    required this.description,
  });

  factory PriceFactor.fromJson(Map<String, dynamic> json) {
    return PriceFactor(
      name: json['name'] as String,
      impact: json['impact'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'impact': impact, 'description': description};
  }
}
