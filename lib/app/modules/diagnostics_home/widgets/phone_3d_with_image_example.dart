import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'phone_3d_widget.dart';
import 'package:kdtd_ver2_1/app/data/services/phone_image_mapper.dart';

/// Example: Sử dụng Phone3DWidget với hình ảnh thực
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
          Text(
            '1. 3D Rendered Phone',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 450,
            child: Phone3DWidget(
              score: 95,
              modelName: 'Galaxy S21',
              brand: 'Samsung',
              color: AppColors.green,
              useRealImage: false,
            ),
          ),

          const SizedBox(height: 40),

          // Example 2: With Real Image (if available)
          Text(
            '2. Real Image Phone',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 450,
            child: Phone3DWidget(
              score: 85,
              modelName: 'Galaxy S21',
              brand: 'Samsung',
              color: AppColors.blue,
              useRealImage: true,
              imageAsset: PhoneImageMapper.getPhoneImage('SM-G991N', 'Samsung'),
            ),
          ),

          const SizedBox(height: 40),

          // Example 3: iPhone
          Text(
            '3. iPhone Example',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 450,
            child: Phone3DWidget(
              score: 90,
              modelName: 'iPhone 15 Pro',
              brand: 'Apple',
              color: AppColors.neutralPurple,
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
    final imagePath = hasCustomImage ? PhoneImageMapper.getPhoneImage(modelName, brand) : null;

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
