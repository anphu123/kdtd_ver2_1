/// Map model name to phone image asset path
class PhoneImageMapper {
  static String getPhoneImage(String modelName, String brand) {
    final model = modelName.toLowerCase();
    final brandLower = brand.toLowerCase();

    // Samsung
    if (brandLower.contains('samsung')) {
      if (model.contains('s24')) return 'assets/phones/samsung_s24.png';
      if (model.contains('s23')) return 'assets/phones/samsung_s23.png';
      if (model.contains('s22')) return 'assets/phones/samsung_s22.png';
      if (model.contains('s21')) return 'assets/phones/samsung_s21.png';
      if (model.contains('s20')) return 'assets/phones/samsung_s20.png';
      if (model.contains('a54')) return 'assets/phones/samsung_a54.png';
      if (model.contains('a34')) return 'assets/phones/samsung_a34.png';
      if (model.contains('fold')) return 'assets/phones/samsung_fold.png';
      if (model.contains('flip')) return 'assets/phones/samsung_flip.png';
      return 'assets/phones/samsung_default.png';
    }

    // iPhone
    if (brandLower.contains('apple') || model.contains('iphone')) {
      if (model.contains('15')) return 'assets/phones/iphone_15.png';
      if (model.contains('14')) return 'assets/phones/iphone_14.png';
      if (model.contains('13')) return 'assets/phones/iphone_13.png';
      if (model.contains('12')) return 'assets/phones/iphone_12.png';
      if (model.contains('11')) return 'assets/phones/iphone_11.png';
      if (model.contains('pro max')) return 'assets/phones/iphone_pro_max.png';
      if (model.contains('pro')) return 'assets/phones/iphone_pro.png';
      return 'assets/phones/iphone_default.png';
    }

    // Xiaomi
    if (brandLower.contains('xiaomi') || brandLower.contains('redmi')) {
      if (model.contains('14')) return 'assets/phones/xiaomi_14.png';
      if (model.contains('13')) return 'assets/phones/xiaomi_13.png';
      if (model.contains('12')) return 'assets/phones/xiaomi_12.png';
      if (model.contains('redmi')) return 'assets/phones/redmi_note.png';
      return 'assets/phones/xiaomi_default.png';
    }

    // Oppo
    if (brandLower.contains('oppo')) {
      if (model.contains('find')) return 'assets/phones/oppo_find.png';
      if (model.contains('reno')) return 'assets/phones/oppo_reno.png';
      return 'assets/phones/oppo_default.png';
    }

    // Vivo
    if (brandLower.contains('vivo')) {
      return 'assets/phones/vivo_default.png';
    }

    // Realme
    if (brandLower.contains('realme')) {
      return 'assets/phones/realme_default.png';
    }

    // Default generic phone
    return 'assets/phones/generic_phone.png';
  }

  /// Check if image exists in assets
  static bool hasCustomImage(String modelName, String brand) {
    final path = getPhoneImage(modelName, brand);
    return !path.contains('default') && !path.contains('generic');
  }

  /// Get online image URL (fallback)
  static String getOnlineImageUrl(String modelName, String brand) {
    // Có thể dùng API hoặc CDN để lấy hình ảnh
    // Ví dụ: GSMArena, PhoneArena, hoặc tự host
    final encodedModel = Uri.encodeComponent(modelName);
    return 'https://fdn2.gsmarena.com/vv/bigpic/$encodedModel.jpg';
  }
}
