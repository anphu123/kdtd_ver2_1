import 'dart:convert';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:kdtd_ver2_1/app/core/constants/price_estimation_constants.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:http/http.dart' as http;

/// Service để ước tính giá thu mua điện thoại
class PriceEstimationService {
  // Thay bằng URL thực
  static const String _baseUrl = PriceEstimationConstants.apiBaseUrl;

  /// Ước tính giá thu mua dựa trên điểm số và thông tin thiết bị
  static Future<PriceEstimate?> estimatePrice({
    required String modelName,
    required String brand,
    required int score,
    required int ramGb,
    required int romGb,
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
           
            }),
          )
          .timeout(PriceEstimationConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PriceEstimate.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error estimating price from API: $e');
    }

    // Fallback: Tính giá local
    return _calculateLocalPrice(
      modelName: modelName,
      brand: brand,
      score: score,
      ramGb: ramGb,
      romGb: romGb,
 
    );
  }

  /// Tính giá local dựa trên logic
  static PriceEstimate _calculateLocalPrice({
    required String modelName,
    required String brand,
    required int score,
    required int ramGb,
    required int romGb,

  }) {
    // Giá cơ bản theo hãng và model
    double basePrice = _getBasePrice(modelName, brand);

    // Điều chỉnh theo RAM/ROM
    basePrice +=
        (ramGb - PriceEstimationConstants.ramBaselineGb) *
        PriceEstimationConstants.pricePerExtraRamGb; // +tiền mỗi GB RAM vượt mốc
    basePrice +=
        (romGb - PriceEstimationConstants.romBaselineGb) /
        PriceEstimationConstants.romStepGb *
        PriceEstimationConstants.pricePerRomStep; // +tiền mỗi bước ROM vượt mốc

    // Điều chỉnh theo điểm số (score)
    double scoreMultiplier = score / 100.0;

    // Giảm giá theo độ hao mòn
    if (score >= PriceEstimationConstants.scoreExcellentMin) {
      scoreMultiplier = PriceEstimationConstants.scoreMultiplierExcellent;
    } else if (score >= PriceEstimationConstants.scoreGoodMin) {
      scoreMultiplier = PriceEstimationConstants.scoreMultiplierGood;
    } else if (score >= PriceEstimationConstants.scoreFairMin) {
      scoreMultiplier = PriceEstimationConstants.scoreMultiplierFair;
    } else if (score >= PriceEstimationConstants.scorePoorMin) {
      scoreMultiplier = PriceEstimationConstants.scoreMultiplierPoor;
    } else {
      scoreMultiplier = PriceEstimationConstants.scoreMultiplierBad;
    }



    final estimatedPrice = basePrice * scoreMultiplier ;
    final minPrice =
        estimatedPrice * (1 - PriceEstimationConstants.priceRangeMargin);
    final maxPrice =
        estimatedPrice * (1 + PriceEstimationConstants.priceRangeMargin);

    return PriceEstimate(
      minPrice: minPrice.round(),
      maxPrice: maxPrice.round(),
      estimatedPrice: estimatedPrice.round(),
      currency: 'VND',
      confidence: _calculateConfidence(score),
      factors: _getPriceFactors(score),
      recommendation: _getRecommendation(score, estimatedPrice),
    );
  }

  /// Lấy giá cơ bản theo model
  static double _getBasePrice(String modelName, String brand) {
    final model = modelName.toUpperCase();
    final brandLower = brand.toLowerCase();

    // Samsung
    if (brandLower.contains('samsung')) {
      if (model.contains('S24')) return PriceEstimationConstants.basePriceSamsungS24;
      if (model.contains('S23')) return PriceEstimationConstants.basePriceSamsungS23;
      if (model.contains('S22')) return PriceEstimationConstants.basePriceSamsungS22;
      if (model.contains('S21')) return PriceEstimationConstants.basePriceSamsungS21;
      if (model.contains('S20')) return PriceEstimationConstants.basePriceSamsungS20;
      if (model.contains('A54')) return PriceEstimationConstants.basePriceSamsungA54;
      if (model.contains('A34')) return PriceEstimationConstants.basePriceSamsungA34;
      if (model.contains('FOLD')) return PriceEstimationConstants.basePriceSamsungFold;
      if (model.contains('FLIP')) return PriceEstimationConstants.basePriceSamsungFlip;
      return PriceEstimationConstants.basePriceSamsungDefault;
    }

    // iPhone
    if (brandLower.contains('apple') || model.contains('IPHONE')) {
      if (model.contains('15')) return PriceEstimationConstants.basePriceIphone15;
      if (model.contains('14')) return PriceEstimationConstants.basePriceIphone14;
      if (model.contains('13')) return PriceEstimationConstants.basePriceIphone13;
      if (model.contains('12')) return PriceEstimationConstants.basePriceIphone12;
      if (model.contains('11')) return PriceEstimationConstants.basePriceIphone11;
      if (model.contains('PRO MAX')) {
        return PriceEstimationConstants.basePriceIphoneProMax;
      }
      return PriceEstimationConstants.basePriceIphoneDefault;
    }

    // Xiaomi
    if (brandLower.contains('xiaomi')) {
      if (model.contains('14')) return PriceEstimationConstants.basePriceXiaomi14;
      if (model.contains('13')) return PriceEstimationConstants.basePriceXiaomi13;
      if (model.contains('12')) return PriceEstimationConstants.basePriceXiaomi12;
      return PriceEstimationConstants.basePriceXiaomiDefault;
    }

    // Oppo
    if (brandLower.contains('oppo')) {
      if (model.contains('FIND')) return PriceEstimationConstants.basePriceOppoFind;
      if (model.contains('RENO')) return PriceEstimationConstants.basePriceOppoReno;
      return PriceEstimationConstants.basePriceOppoDefault;
    }

    // Default
    return PriceEstimationConstants.basePriceUnknown;
  }

  /// Tính độ tin cậy của ước tính
  static double _calculateConfidence(int score) {
    if (score >= PriceEstimationConstants.scoreExcellentMin) {
      return PriceEstimationConstants.confidenceExcellent;
    }
    if (score >= PriceEstimationConstants.scoreGoodMin) {
      return PriceEstimationConstants.confidenceGood;
    }
    if (score >= PriceEstimationConstants.scoreFairMin) {
      return PriceEstimationConstants.confidenceFair;
    }
    if (score >= PriceEstimationConstants.scorePoorMin) {
      return PriceEstimationConstants.confidencePoor;
    }
    return PriceEstimationConstants.confidenceBad;
  }

  /// Lấy các yếu tố ảnh hưởng giá
  static List<PriceFactor> _getPriceFactors(int score) {
    final factors = <PriceFactor>[];

    // Điểm số
    if (score >= PriceEstimationConstants.scoreExcellentMin) {
      factors.add(
        PriceFactor(
          name: LocaleKeys.price_estimation_condition_excellent_name.trans(),
          impact: 'positive',
          description:
              LocaleKeys.price_estimation_condition_excellent_description.trans(),
        ),
      );
    } else if (score >= PriceEstimationConstants.scoreGoodMin) {
      factors.add(
        PriceFactor(
          name: LocaleKeys.price_estimation_condition_good_name.trans(),
          impact: 'neutral',
          description:
              LocaleKeys.price_estimation_condition_good_description.trans(),
        ),
      );
    } else if (score >= PriceEstimationConstants.scoreFairMin) {
      factors.add(
        PriceFactor(
          name: LocaleKeys.price_estimation_condition_fair_name.trans(),
          impact: 'negative',
          description:
              LocaleKeys.price_estimation_condition_fair_description.trans(),
        ),
      );
    } else {
      factors.add(
        PriceFactor(
          name: LocaleKeys.price_estimation_condition_poor_name.trans(),
          impact: 'negative',
          description:
              LocaleKeys.price_estimation_condition_poor_description.trans(),
        ),
      );
    }



    return factors;
  }

  /// Lấy khuyến nghị
  static String _getRecommendation(int score, double price) {
    if (score >= PriceEstimationConstants.scoreExcellentMin) {
      return LocaleKeys.price_estimation_recommendation_excellent.trans();
    } else if (score >= PriceEstimationConstants.scoreGoodMin) {
      return LocaleKeys.price_estimation_recommendation_good.trans();
    } else if (score >= PriceEstimationConstants.scoreFairMin) {
      return LocaleKeys.price_estimation_recommendation_fair.trans();
    } else if (score >= PriceEstimationConstants.scorePoorMin) {
      return LocaleKeys.price_estimation_recommendation_poor.trans();
    } else {
      return LocaleKeys.price_estimation_recommendation_bad.trans();
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
