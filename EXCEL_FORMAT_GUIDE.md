# Hướng dẫn Format File Excel

## 1. TC_list.xlsx - Danh sách thiết bị

### Cấu trúc cột:

| Column | Tên | Kiểu dữ liệu | Ví dụ | Ghi chú |
|--------|-----|--------------|-------|---------|
| A | Model Name | Text | SM-G991N | Model code chính thức |
| B | Marketing Name | Text | Samsung Galaxy S21 5G | Tên thương mại |
| C | Brand | Text | Samsung | Hãng sản xuất |
| D | Base Price | Number | 10000000 | Giá gốc (VND) |
| E | RAM (GB) | Number | 8 | Dung lượng RAM |
| F | ROM (GB) | Number | 128 | Dung lượng ROM |
| G | Release Year | Number | 2021 | Năm ra mắt |

### Ví dụ:

```
Model Name | Marketing Name      | Brand   | Base Price | RAM | ROM | Year
SM-G991N   | Galaxy S21 5G       | Samsung | 10000000   | 8   | 128 | 2021
SM-G996N   | Galaxy S21+ 5G      | Samsung | 12000000   | 8   | 256 | 2021
iPhone14,2 | iPhone 13 Pro       | Apple   | 25000000   | 6   | 128 | 2021
2201123G   | Xiaomi 12           | Xiaomi  | 12000000   | 8   | 256 | 2022
```

---

## 2. Data_2Hand_Tradein_T92025.xlsx - Giá thu mua theo tháng

### Cấu trúc cột:

| Column | Tên | Kiểu dữ liệu | Ví dụ | Ghi chú |
|--------|-----|--------------|-------|---------|
| A | Model Name | Text | SM-G991N | Model code |
| B | Month | Text | T9/2025 | Tháng (format: T{month}/{year}) |
| C | Grade A | Number | 9000000 | Giá Grade A (90-100 điểm) |
| D | Grade B | Number | 7500000 | Giá Grade B (80-89 điểm) |
| E | Grade C | Number | 6000000 | Giá Grade C (70-79 điểm) |
| F | Grade D | Number | 4500000 | Giá Grade D (<70 điểm) |

### Ví dụ:

```
Model    | Month   | Grade A  | Grade B  | Grade C  | Grade D
SM-G991N | T9/2025 | 9000000  | 7500000  | 6000000  | 4500000
SM-G991N | T8/2025 | 9200000  | 7700000  | 6200000  | 4700000
SM-G996N | T9/2025 | 10500000 | 8800000  | 7000000  | 5200000
iPhone14,2| T9/2025| 22000000 | 18500000 | 15000000 | 12000000
```

---

## 3. Quy tắc Grade (Phân loại)

| Grade | Điểm | Mô tả | % Giá gốc |
|-------|------|-------|-----------|
| A | 90-100 | Xuất sắc - Như mới | 85-90% |
| B | 80-89 | Tốt - Vài vết xước nhỏ | 70-80% |
| C | 70-79 | Khá - Có dấu hiệu sử dụng | 55-65% |
| D | <70 | Trung bình/Yếu - Nhiều vấn đề | 40-50% |

---

## 4. Cách sử dụng trong App

### Import Data:
1. Mở Admin Panel
2. Chọn "Import Data"
3. Upload file TC_list.xlsx
4. Upload file Data_2Hand_Tradein_T92025.xlsx
5. Nhấn "Import tất cả"

### Tính giá tự động:
```dart
// App sẽ tự động:
1. Lấy model name từ device
2. Tính điểm score (0-100)
3. Chuyển score → grade (A/B/C/D)
4. Lấy tháng hiện tại
5. Tra cứu giá từ Excel data
6. Hiển thị giá thu mua
```

---

## 5. Cập nhật giá hàng tháng

### Quy trình:
1. Tạo file mới: `Data_2Hand_Tradein_T{month}{year}.xlsx`
2. Copy format từ file cũ
3. Cập nhật giá mới cho tháng mới
4. Import vào app
5. App tự động dùng giá tháng hiện tại

### Ví dụ tên file:
- `Data_2Hand_Tradein_T92025.xlsx` (Tháng 9/2025)
- `Data_2Hand_Tradein_T102025.xlsx` (Tháng 10/2025)
- `Data_2Hand_Tradein_T112025.xlsx` (Tháng 11/2025)

---

## 6. Tips & Best Practices

### ✅ Nên:
- Giữ format cột đúng thứ tự
- Dùng số nguyên cho giá (không dấu phẩy, chấm)
- Cập nhật giá đều đặn mỗi tháng
- Backup file Excel trước khi import
- Kiểm tra data sau khi import

### ❌ Không nên:
- Thay đổi tên cột header
- Để trống model name
- Dùng ký tự đặc biệt trong model name
- Nhập giá âm hoặc 0
- Xóa dữ liệu cũ trước khi có backup

---

## 7. Troubleshooting

### Lỗi import:
- **"Error parsing row"**: Kiểm tra format cột, đảm bảo đúng thứ tự
- **"No data imported"**: File có thể bị corrupt, thử export lại
- **"Invalid price"**: Giá phải là số nguyên dương

### Giá không hiển thị:
- Kiểm tra model name có khớp giữa 2 file
- Kiểm tra tháng hiện tại có trong data
- Xem log console để debug

---

## 8. API Integration (Optional)

Nếu muốn sync với backend:

```
POST /api/admin/import/devices
Body: [DeviceModel array]

POST /api/admin/import/prices
Body: [MonthlyPrice array]

GET /api/price/current?model={model}&score={score}
Response: { price: 9000000, grade: "A", month: "T9/2025" }
```
