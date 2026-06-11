# EduAdmin - Nhập Điểm Screen Refactoring

## 📋 Mô tả
Đã refactor file `nhapdiem_screen.dart` (700+ dòng code rối) thành cấu trúc modular với các widget riêng biệt, dễ bảo trì và phát triển.

## 📁 Cấu trúc Thư Mục

```
adminui/
├── nhapdiem_screen.dart          (File chính - 280 dòng, gọn gàng)
└── widgets_admin/                (Thư mục chứa các widget con)
    ├── index.dart                (Export file - import tất cả)
    ├── app_colors.dart           (Màu sắc & theme toàn cục)
    ├── score_utils.dart          (Tiện ích tính điểm)
    ├── top_bar_widget.dart       (Top bar desktop/mobile)
    ├── page_header_widget.dart   (Header trang "Nhập điểm")
    ├── filter_and_stats_widget.dart  (Bộ lọc & thống kê)
    ├── score_input_field.dart    (Input điểm & hàng bảng)
    ├── table_section_widget.dart (Bảng chính & pagination)
    └── student_dialogs.dart      (Dialog thêm/sửa/xóa)
```

## 🎯 Lợi Ích Của Refactoring

| Trước | Sau |
|------|-----|
| 1 file 700+ dòng | 9 file nhỏ, mục đích rõ ràng |
| Màu sắc hardcoded khắp nơi | Tập trung ở `AppColors` |
| Logic tính điểm lộn xộn | Tách sang `ScoreUtils` |
| Dialog code lặp lại | Tập trung ở `StudentDialogs` |
| Khó mở rộng | Dễ thêm feature mới |
| Khó test | Có thể test từng widget |

## 📦 Cách Sử Dụng

### Import tất cả widgets
```dart
import 'widgets_admin/index.dart';
```

### Sử dụng trong NhapDiemScreen
```dart
// Top bar
TopBarWidget(isDesktop: isDesktop)

// Filter & Stats
FilterAndStatsWidget(
  selectedMonHoc: _selectedMonHoc,
  selectedLopHoc: _selectedLopHoc,
  danhSachLop: _danhSachLop,
  studentData: _studentData,
  onMonHocChanged: (value) { ... },
  onLopHocChanged: (value) { ... },
)

// Table
TableSectionWidget(
  studentData: _studentData,
  controllers: _controllers,
  onUpdateScore: _updateScore,
  onEdit: _editStudent,
  onDelete: _deleteStudent,
  currentPage: _currentPage,
  onPageChanged: (page) { ... },
)
```

## 🎨 Màu Sắc (AppColors)

```dart
AppColors.primaryColor         // 0xFF006491
AppColors.successGreen         // 0xFF117A65
AppColors.errorRed             // 0xFFC0392B
AppColors.accentBlue           // 0xFF5DADE2
AppColors.backgroundColor      // 0xFFF7F9FF
AppColors.surfaceColor         // 0xFFFFFFFF
```

## 📊 Tiện Ích Điểm (ScoreUtils)

```dart
// Tính điểm trung bình
double dtb = ScoreUtils.calculateDTB(gk, ck);

// Lấy trạng thái
String status = ScoreUtils.getStatus(dtb);  // "Đạt", "Trượt", "Chưa nhập"

// Lấy màu trạng thái
Color color = ScoreUtils.getStatusColor(status);

// Tính DTB lớp
double classAvg = ScoreUtils.calculateClassAverage(studentData);
```

## 💬 Dialog Sinh Viên (StudentDialogs)

```dart
// Thêm sinh viên
Map<String, String>? result = await StudentDialogs.showAddStudentDialog(context);
if (result != null) {
  print('MSSV: ${result['mssv']}');
  print('Tên: ${result['ten']}');
}

// Sửa sinh viên
Map<String, String>? result = await StudentDialogs.showEditStudentDialog(
  context, 
  currentMssv, 
  currentName,
);

// Xác nhận xóa
bool? confirmed = await StudentDialogs.showDeleteConfirmDialog(context);
if (confirmed == true) { ... }
```

## 🔧 Thêm Màu Mới

1. Mở `app_colors.dart`
2. Thêm constant mới:
```dart
static const Color myCustomColor = Color(0xFFFFFFFF);
```
3. Sử dụng ở bất cứ đâu:
```dart
Container(color: AppColors.myCustomColor)
```

## 🚀 Mở Rộng Tính Năng

### Thêm Widget Mới
1. Tạo file `new_feature_widget.dart` trong `widgets_admin/`
2. Tạo class widget
3. Thêm export vào `index.dart`
4. Sử dụng trong `nhapdiem_screen.dart`

### Thêm Utility Mới
1. Tạo file `new_utils.dart` trong `widgets_admin/`
2. Tạo class utility
3. Thêm export vào `index.dart`

## ⚠️ Lưu Ý

- **Kiểm tra Null Safety**: Model phải có type annotations rõ ràng
- **Màu Sắc**: Luôn dùng `AppColors` thay vì hardcoded
- **Đặt Tên**: File widget phải có suffix `_widget.dart`
- **Exports**: Cập nhật `index.dart` khi thêm file mới

## 📝 Các Method Chính Trong NhapDiemScreen

```dart
_addStudent()          // Hiển thị dialog thêm
_editStudent(index)    // Sửa sinh viên
_deleteStudent(index)  // Xóa sinh viên
_updateScore()         // Cập nhật điểm
_loadStudentData()     // Tải dữ liệu từ AppData
_buildMainContent()    // Build UI chính
```

## ✅ Kiểm Tra Chất Lượng

```bash
# Format code
flutter format lib/ui/adminui/

# Kiểm tra lỗi
flutter analyze lib/ui/adminui/

# Run app
flutter run
```

---

**Tác giả**: GitHub Copilot  
**Ngày refactor**: 2026-06-05  
**Phiên bản**: v1.0
