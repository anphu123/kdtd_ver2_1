import 'package:flutter/material.dart';
import 'phone_3d_widget.dart';
import '../../utils/phone_image_mapper.dart';

/// Example: Sử dụng Phone3DWidget với hình ảnh thực
///
/// Cách 1: Dùng asset image
/// ```dart
/// Phone3DWidget(
///   score: 95,
///   modelName: 'Galaxy S21',
///   brand: 'Samsung',
///   color: Colors.green,
///   useRealImage: true,
///   imageAsset: 'assets/phones/samsung_s21.png',
/// )
/// ```
///
/// Cách 2: Dùng PhoneImageMapper
/// ```dart
/// final imagePath = PhoneImageMapper.getPhoneImage(modelName, brand);
/// Phone3DWidget(
///   score: 95,
///   modelName: modelName,
///   brand: brand,
///   color: Colors.green,
///   useRealImage: true,
///   imageAsset: imagePath,
/// )
/// ```
///
/// Cách 3: Load từ network (cần NetworkImage)
/// ```dart
/// // Trong Phone3DWidget, thêm support cho network image
/// final imageUrl = await PhoneInfoService.getPhoneImageUrl(modelName, brand);
/// ```

class Phone3DWithImageExample extends StatelessWidget {
  const Phone3DWithImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone 3D Examples')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Example 1: 3D Rendered (no image)
          const Text(
            '1. 3D Rendered Phone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 450,
            child: Phone3DWidget(
              score: 95,
              modelName: 'Galaxy S21',
              brand: 'Samsung',
              color: Colors.green,
              useRealImage: false,
            ),
          ),

          const SizedBox(height: 40),

          // Example 2: With Real Image (if available)
          const Text(
            '2. Real Image Phone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 450,
            child: Phone3DWidget(
              score: 85,
              modelName: 'Galaxy S21',
              brand: 'Samsung',
              color: Colors.blue,
              useRealImage: true,
              imageAsset: PhoneImageMapper.getPhoneImage('SM-G991N', 'Samsung'),
            ),
          ),

          const SizedBox(height: 40),

          // Example 3: iPhone
          const Text(
            '3. iPhone Example',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 450,
            child: Phone3DWidget(
              score: 90,
              modelName: 'iPhone 15 Pro',
              brand: 'Apple',
              color: Colors.purple,
              useRealImage: true,
              imageAsset: PhoneImageMapper.getPhoneImage('iPhone15,2', 'Apple'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget helper để hiển thị phone với auto image detection
class SmartPhone3DWidget extends StatelessWidget {
  final int score;
  final String modelName;
  final String brand;
  final Color color;

  const SmartPhone3DWidget({
    super.key,
    required this.score,
    required this.modelName,
    required this.brand,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Auto detect if custom image exists
    final hasCustomImage = PhoneImageMapper.hasCustomImage(modelName, brand);
    final imagePath =
        hasCustomImage
            ? PhoneImageMapper.getPhoneImage(modelName, brand)
            : null;

    return Phone3DWidget(
      score: score,
      modelName: modelName,
      brand: brand,
      color: color,
      useRealImage: hasCustomImage,
      imageAsset: imagePath,
    );
  }
}
