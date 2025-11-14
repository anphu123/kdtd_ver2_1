# Hướng dẫn Setup Hình ảnh Điện thoại

## 1. Cấu trúc thư mục

Tạo thư mục `assets/phones/` trong project:

```
assets/
  phones/
    samsung_s24.png
    samsung_s23.png
    samsung_s22.png
    samsung_s21.png
    samsung_a54.png
    iphone_15.png
    iphone_14.png
    iphone_13.png
    xiaomi_14.png
    generic_phone.png
```

## 2. Cập nhật pubspec.yaml

```yaml
flutter:
  assets:
    - assets/phones/
```

## 3. Nguồn hình ảnh

### Option 1: GSMArena
- Truy cập: https://www.gsmarena.com/
- Tìm model điện thoại
- Download hình ảnh chất lượng cao
- Crop và resize về 400x800px (hoặc tỷ lệ tương tự)

### Option 2: Tự chụp
- Chụp ảnh điện thoại trên nền trắng
- Dùng tool remove background (remove.bg)
- Resize về kích thước phù hợp

### Option 3: API/CDN
Sử dụng PhoneInfoService để load từ server:

```dart
final imageUrl = await PhoneInfoService.getPhoneImageUrl(modelName, brand);
// Sau đó dùng Image.network(imageUrl)
```

## 4. Quy chuẩn đặt tên file

Format: `{brand}_{model}.png`

Ví dụ:
- Samsung Galaxy S21 → `samsung_s21.png`
- iPhone 15 Pro → `iphone_15_pro.png`
- Xiaomi 14 → `xiaomi_14.png`

## 5. Kích thước khuyến nghị

- Width: 400-600px
- Height: 800-1200px
- Format: PNG với transparent background
- File size: < 500KB

## 6. Sử dụng trong code

### Cách 1: Dùng asset
```dart
Phone3DWidget(
  score: 95,
  modelName: 'Galaxy S21',
  brand: 'Samsung',
  color: Colors.green,
  useRealImage: true,
  imageAsset: 'assets/phones/samsung_s21.png',
)
```

### Cách 2: Dùng PhoneImageMapper
```dart
final imagePath = PhoneImageMapper.getPhoneImage(modelName, brand);
Phone3DWidget(
  score: 95,
  modelName: modelName,
  brand: brand,
  color: Colors.green,
  useRealImage: true,
  imageAsset: imagePath,
)
```

### Cách 3: Smart auto-detect
```dart
SmartPhone3DWidget(
  score: 95,
  modelName: modelName,
  brand: brand,
  color: Colors.green,
)
```

## 7. Fallback

Nếu không tìm thấy hình ảnh:
- Sẽ tự động fallback về 3D rendered phone
- Hoặc dùng `generic_phone.png`

## 8. Network Images (Advanced)

Để load từ URL:

1. Cập nhật `Phone3DWidget` để support network image:

```dart
final String? imageUrl;
final String? imageAsset;

// Trong build:
if (imageUrl != null) {
  Image.network(imageUrl, ...)
} else if (imageAsset != null) {
  Image.asset(imageAsset, ...)
}
```

2. Sử dụng:

```dart
final imageUrl = await controller.getPhoneImageUrl();
Phone3DWidget(
  score: 95,
  modelName: modelName,
  brand: brand,
  color: Colors.green,
  useRealImage: true,
  imageUrl: imageUrl,
)
```

## 9. Caching (Recommended)

Dùng `cached_network_image` package:

```yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => _build3DRenderedPhone(),
)
```

## 10. Backend API Setup

Nếu dùng API, cần implement endpoints:

```
GET /api/phone/image?model={model}&brand={brand}
Response: { "imageUrl": "https://cdn.example.com/phones/samsung_s21.png" }
```

Hoặc dùng CDN pattern:
```
https://cdn.example.com/phones/{brand}_{model}.png
```
