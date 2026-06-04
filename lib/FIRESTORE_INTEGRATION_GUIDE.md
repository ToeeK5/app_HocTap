# Hướng Dẫn Tích Hợp Firestore - Hoàn Chỉnh

## 📋 Tổng Quan

Ứng dụng đã được hoàn toàn chuyển sang sử dụng Firestore thay vì AppData cho quản lý sinh viên và điểm số. Dữ liệu mẫu sẽ được tự động khởi tạo lần đầu tiên ứng dụng chạy.

## 🏗️ Kiến Trúc Dữ Liệu Firestore

### Collection: `sinh_vien`
```
Document ID: maSV (e.g., "SV001")
Fields:
  - maSV: String (ID)
  - hoTen: String
  - lop: String (CNTT1, CNTT2, CNTT3, CNTT4)
  - email: String
  - sdt: String (optional)
  - namSinh: int
  - hocKyHienTai: int
  - createdAt: Timestamp
```

### Collection: `diem`
```
Document ID: "{maSV}_{maMon}" (e.g., "SV001_MH001")
Fields:
  - maSV: String
  - maMon: String (MH001, MH002, MH003)
  - diemGiuaKy: double
  - diemCuoiKy: double
  - heSoGiuaKy: double (default: 0.4)
  - heSoCuoiKy: double (default: 0.6)
  - updatedAt: Timestamp
  - note: String (optional)
```

## 🚀 Khởi Động Ứng Dụng

### 1. Khởi Tạo Dữ Liệu Mẫu

Lần đầu tiên ứng dụng chạy, dữ liệu mẫu sẽ được tự động khởi tạo. Để xem Firestore Dashboard:

```bash
# Mở Firebase Console
https://console.firebase.google.com/
# Project: app_hoctap (hoặc tên project của bạn)
# Firestore: Collections → sinh_vien, diem
```

#### Dữ Liệu Mẫu Gồm:

**CNTT1** (5 sinh viên):
- SV001: Nguyễn Văn A
- SV002: Trần Thị B  
- SV003: Phạm Văn C
- SV004: Lê Thị D
- SV005: Hoàng Văn E

**CNTT2** (5 sinh viên):
- SV006: Vũ Thị F
- SV007: Đinh Văn G
- SV008: Bùi Thị H
- SV009: Đỗ Văn I
- SV010: Ngô Thị K

**CNTT3** (4 sinh viên):
- SV011: Trương Văn L
- SV012: Phan Thị M
- SV013: Dương Văn N
- SV014: Võ Thị O

**CNTT4** (3 sinh viên):
- SV015: Tô Văn P
- SV016: Nông Thị Q
- SV017: Tạ Văn R

### 2. Môn Học (Hiện Tại từ AppData)

Mặc dù sinh viên đã chuyển sang Firestore, danh sách môn học vẫn được định nghĩa trong code:

```dart
// lib/ui/adminui/nhapdiem_screen.dart
List<String> _danhSachMonHoc = ['MH001', 'MH002', 'MH003'];
```

Bạn có thể:
- Giữ nguyên (môn học từ AppData/hardcoded)
- Hoặc migrate sang Firestore (thêm collection `mon_hoc`)

## 📱 Các Screen Chính

### 1. Admin Dashboard (`lib/ui/adminui/admin_dashboard.dart`)

**Tác dụng**: Quản lý dữ liệu Firestore

**Features**:
- ✅ **Khởi Tạo Dữ Liệu**: Tạo 17 sinh viên mẫu (chỉ lần đầu)
- ✅ **Xóa Dữ Liệu**: Xóa tất cả sinh viên + điểm (dùng test)

**Cách Truy Cập**:
```dart
// Thêm route vào main.dart hoặc navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AdminDashboard()),
);
```

### 2. Nhập Điểm Screen (`lib/ui/adminui/nhapdiem_screen.dart`)

**Tác dụng**: Nhập điểm sinh viên từ Firestore

**Key Changes**:
- ❌ Không còn dùng `AppData.danhSachSinhVien`
- ✅ Dùng `FirestoreService.getSinhVienList()`
- ✅ Hiển thị tất cả sinh viên (không filter theo lớp)
- ✅ Tự động sắp xếp theo lớp rồi tên

**State Variables**:
```dart
List<String> _danhSachMonHoc = ['MH001', 'MH002', 'MH003'];
String _selectedMonHoc = '';
List<Map<String, dynamic>> _studentData = [];
bool _isLoading = true;
```

**Main Methods**:
- `_loadInitialData()`: Khởi tạo Firestore + tải sinh viên
- `_loadStudentDataFromFirestore()`: Lấy sinh viên từ Firestore
- `_saveAllScores()`: Lưu tất cả điểm vào Firestore
- `_addStudent()`: Thêm sinh viên mới
- `_deleteStudent(maSV)`: Xóa sinh viên
- `_editStudent(maSV)`: Sửa thông tin sinh viên

## 🔧 Services

### FirestoreService (`lib/services/firestore_service.dart`)

```dart
// Lấy danh sách sinh viên
List<SinhVien> students = await _firestoreService.getSinhVienList();

// Lấy sinh viên theo lớp
List<SinhVien> cntt1 = await _firestoreService.getSinhVienByLop('CNTT1');

// Thêm sinh viên
await _firestoreService.addSinhVien(sinhVienModel);

// Cập nhật sinh viên
await _firestoreService.updateSinhVien(maSV, updateData);

// Xóa sinh viên
await _firestoreService.deleteSinhVien(maSV);

// Lấy điểm theo môn học
List<Diem> scores = await _firestoreService.getDiemByMonHoc('MH001');

// Lưu điểm
await _firestoreService.saveDiem(diemModel);

// Lưu batch điểm
await _firestoreService.saveBatchDiem(diemList);

// Stream real-time điểm
Stream<List<Diem>> stream = _firestoreService.streamDiemByMonHoc('MH001');
```

### AdminService (`lib/services/admin_service.dart`)

```dart
// Thêm sinh viên đơn lẻ
String? error = await _adminService.addSingleSinhVien(sinhVienModel);

// Thêm batch sinh viên
Map<String, dynamic> result = await _adminService.addBatchSinhVien(sinhVienList);
// Result: { success: int, failed: int, errors: List<String> }

// Lấy danh sách sinh viên theo lớp
List<SinhVien> students = await _adminService.getSinhVienByLop('CNTT1');

// Thống kê điểm theo môn
Map<String, dynamic> stats = await _adminService.getDiemStats('MH001');
// Stats: { total: int, passed: int, failed: int, average: double }
```

### InitDataService (`lib/services/init_data_service.dart`)

```dart
// Kiểm tra dữ liệu đã được khởi tạo chưa
bool isInitialized = await _initDataService.isDataInitialized();

// Khởi tạo dữ liệu lần đầu (idempotent)
bool success = await _initDataService.initializeSinhVienData();

// Xóa tất cả dữ liệu (dùng test)
bool success = await _initDataService.clearAllData();
```

## 🔐 Quy Tắc Bảo Mật (Firestore Rules)

Hiện tại, ứng dụng giả định Firebase Auth đã được cấu hình. Hãy thêm rules này:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Chỉ authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Hoặc cho phép tất cả (chỉ test):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## 🐛 Troubleshooting

### Problem: "PlatformException: Failed to get document"
**Solution**: Kiểm tra Firebase kết nối, rules permissions

### Problem: Dữ liệu không hiển thị
**Solution**:
1. Kiểm tra Firestore collections tồn tại
2. Chạy `AdminDashboard` → "Khởi Tạo Dữ Liệu"
3. Check `isDataInitialized()` return value

### Problem: Điểm không lưu được
**Solution**:
1. Kiểm tra `_diem` collection tồn tại
2. Xác nhận document ID format: `{maSV}_{maMon}`
3. Check Firestore rules cho phép write

### Problem: "Null check operator used on a null value"
**Solution**: Kiểm tra `_studentData` load đúng trước khi build UI

## 📚 Model Serialization

### SinhVien Model
```dart
// Từ Firestore
SinhVien student = SinhVien.fromFirestore(firestoreMap);

// Sang Firestore
Map<String, dynamic> data = student.toFirestore();
```

### Diem Model
```dart
// Từ Firestore
Diem score = Diem.fromFirestore(firestoreMap);

// Sang Firestore
Map<String, dynamic> data = score.toFirestore();

// Tính ĐTB
double avg = score.getDTB();  // diemGiuaKy * 0.4 + diemCuoiKy * 0.6
```

## ✅ Checklist Cập Nhật

- [x] FirestoreService tạo xong
- [x] AdminService tạo xong  
- [x] InitDataService tạo xong (17 sample students)
- [x] SinhVien model Firestore methods
- [x] Diem model Firestore methods
- [x] NhapDiemScreen chuyển sang Firestore
- [x] FilterAndStatsWidget không dùng AppData
- [x] AdminDashboard tạo xong
- [ ] Test Firestore connectivity
- [ ] Test InitDataService idempotency
- [ ] Test add/edit/delete students
- [ ] Test score save (batch)
- [ ] Update Firebase rules

## 🔗 Tài Liệu Liên Quan

- Firebase Docs: https://firebase.google.com/docs/firestore
- Dart Cloud Firestore: https://pub.dev/packages/cloud_firestore
- Flutter Firebase Setup: https://firebase.flutter.dev/docs/overview

---

**Last Updated**: 2024
**Status**: ✅ Integration Complete - Ready for Testing
