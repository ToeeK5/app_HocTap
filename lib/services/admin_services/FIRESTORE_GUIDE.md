# Hướng Dẫn Tích Hợp Firestore - Nhập Điểm Screen

## 📋 Tóm Tắt Thay Đổi

### ✨ Tính Năng Mới
- ✅ Lưu dữ liệu sinh viên vào **Firestore** (không dùng AppData nữa)
- ✅ Lưu điểm vào **Firestore** (có thể lưu hàng loạt)
- ✅ Khi **thêm sinh viên**, chọn **lớp từ 1 đến 4** (CNTT1, CNTT2, CNTT3, CNTT4)
- ✅ **Bỏ filter lớp** khỏi giao diện nhập điểm (chỉ filter môn học)
- ✅ Hiển thị tất cả sinh viên từ tất cả lớp

### 🔧 Service Classes
1. **FirestoreService** - Quản lý các thao tác Firestore
2. **AdminService** - Quản lý việc thêm sinh viên hàng loạt

---

## 📁 Cấu Trúc File

```
lib/
├── services/
│   ├── firestore_service.dart        ← Quản lý Firestore
│   ├── admin_service.dart            ← Quản lý admin
│   └── ...
├── models/
│   ├── sinh_vien.dart                ← Cập nhật: thêm fromFirestore()
│   ├── diem.dart                     ← Cập nhật: thêm fromFirestore()
│   └── ...
└── ui/
    └── adminui/
        ├── nhapdiem_screen.dart      ← Refactor dùng Firestore
        └── widgets_admin/
            ├── filter_and_stats_widget.dart  ← Bỏ filter lớp
            ├── student_dialogs.dart          ← Thêm chọn lớp
            └── ...
```

---

## 🚀 Cách Sử Dụng

### 1. Thêm Sinh Viên Với Lựa Chọn Lớp

**Giao diện:**
- Click button "Thêm sinh viên"
- Dialog hiển thị 3 input: MSSV, Tên, Chọn lớp (dropdown)
- Chọn lớp từ: CNTT1, CNTT2, CNTT3, CNTT4

**Backend:**
```dart
// Tự động lưu vào Firestore
bool success = await adminService.addSingleSinhVien(
  maSV: 'SV001',
  hoTen: 'Nguyễn Văn A',
  lop: 'CNTT1',
);
```

### 2. Nhập Điểm Và Lưu Vào Firestore

**Giao diện:**
- Chỉ filter theo **Môn Học** (không còn filter lớp)
- Hiển thị **tất cả sinh viên** từ tất cả lớp
- Nhập điểm (Giữa kỳ, Cuối kỳ)
- Click "Lưu bảng điểm" → lưu tất cả vào Firestore

**Firestore Structure:**
```
Collection: sinh_vien
├── SV001
│   ├── maSV: "SV001"
│   ├── hoTen: "Nguyễn Văn A"
│   ├── lop: "CNTT1"
│   ├── email: "..."
│   └── sdt: "..."
└── SV002
    └── ...

Collection: diem
├── SV001_MH001
│   ├── maSV: "SV001"
│   ├── maMon: "MH001"
│   ├── diemGiuaKy: 8.5
│   ├── diemCuoiKy: 9.0
│   └── updatedAt: timestamp
└── ...
```

---

## 📚 API References

### FirestoreService

```dart
final service = FirestoreService();

// Lấy danh sách sinh viên
List<SinhVien> svList = await service.getSinhVienList();

// Lấy sinh viên theo lớp
List<SinhVien> svCNTT1 = await service.getSinhVienByLop('CNTT1');

// Thêm sinh viên
bool success = await service.addSinhVien(sinhVien);

// Cập nhật sinh viên
bool success = await service.updateSinhVien('SV001', {'hoTen': 'Nguyễn Văn B'});

// Xóa sinh viên
bool success = await service.deleteSinhVien('SV001');

// Lấy điểm sinh viên
Diem? diem = await service.getDiemBySinhVienAndMonHoc('SV001', 'MH001');

// Lấy danh sách điểm theo môn học
List<Diem> diemList = await service.getDiemByMonHoc('MH001');

// Lưu điểm
bool success = await service.saveDiem(diem);

// Lưu hàng loạt điểm
bool success = await service.saveBatchDiem(diemList);

// Stream điểm theo môn
Stream<List<Diem>> diemStream = service.streamDiemByMonHoc('MH001');
```

### AdminService

```dart
final adminService = AdminService();

// Thêm một sinh viên
bool success = await adminService.addSingleSinhVien(
  maSV: 'SV001',
  hoTen: 'Nguyễn Văn A',
  lop: 'CNTT1',
  email: 'email@example.com',
  sdt: '0901234567',
);

// Thêm hàng loạt sinh viên
Map<String, dynamic> result = await adminService.addBatchSinhVien([
  {'maSV': 'SV001', 'hoTen': 'Nguyễn Văn A', 'lop': 'CNTT1'},
  {'maSV': 'SV002', 'hoTen': 'Trần Thị B', 'lop': 'CNTT2'},
]);
// result: {success: 2, failed: 0, errors: [], total: 2}

// Lấy sinh viên theo lớp
List<SinhVien> sv = await adminService.getSinhVienByLop('CNTT1');

// Lấy sinh viên chưa có điểm
List<SinhVien> svNoGrade = await adminService.getSinhVienWithoutDiem('MH001', 'CNTT1');

// Lấy thống kê điểm
Map<String, dynamic> stats = await adminService.getDiemStats('MH001', 'CNTT1');
// stats: {
//   totalSV: 25,
//   totalWithDiem: 20,
//   totalWithoutDiem: 5,
//   averageDTB: 7.2,
//   passCount: 18,
//   failCount: 2,
//   passRate: "90.0"
// }

// Tạo dữ liệu mẫu cho các lớp
bool success = await adminService.createSampleData();
```

---

## 🔑 Luồng Xử Lý

### Thêm Sinh Viên
```
Dialog → Nhập MSSV/Tên/Chọn Lớp
    ↓
Kiểm tra MSSV đã tồn tại?
    ↓ (Chưa)
Thêm vào Firestore
    ↓
Reload danh sách sinh viên
    ↓
Hiển thị thông báo thành công
```

### Nhập & Lưu Điểm
```
Chọn Môn Học
    ↓
Tải danh sách sinh viên từ Firestore
    ↓
Nhập điểm (Giữa kỳ, Cuối kỳ)
    ↓
Click "Lưu bảng điểm"
    ↓
Tạo danh sách Diem objects
    ↓
Lưu hàng loạt vào Firestore (batch write)
    ↓
Hiển thị kết quả (x điểm đã lưu)
```

---

## ⚠️ Lưu Ý Quan Trọng

1. **Firestore Rules**: Cần cấu hình security rules cho Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /sinh_vien/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /diem/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

2. **Model Update**: Cần update model để có `fromFirestore()` method
```dart
factory SinhVien.fromFirestore(Map<String, dynamic> data) {
  return SinhVien(
    maSV: data['maSV'] ?? '',
    hoTen: data['hoTen'] ?? '',
    email: data['email'] ?? '',
    namSinh: data['namSinh'] ?? 2000,
    lop: data['lop'] ?? '',
    hocKyHienTai: data['hocKyHienTai'] ?? 1,
    sdt: data['sdt'],
  );
}
```

3. **Batch Write Limit**: Firestore batch write limit = 500 documents
   - Nếu có >500 sinh viên, chia thành nhiều batch

4. **Real-time Updates**: Có thể dùng stream để real-time update
```dart
service.streamDiemByMonHoc('MH001').listen((diemList) {
  // Auto update khi có thay đổi
});
```

---

## 🧪 Test Dữ Liệu Mẫu

```dart
// Tạo dữ liệu mẫu
bool success = await adminService.createSampleData();
// Sinh viên mẫu:
// - CNTT1: SV001, SV002, SV003
// - CNTT2: SV004, SV005
// - CNTT3: SV006
// - CNTT4: SV007
```

---

## 🐛 Debug & Troubleshooting

### Sinh viên không hiển thị
1. Kiểm tra Firestore có dữ liệu không
2. Kiểm tra `fromFirestore()` method trong model
3. Kiểm tra network connection

### Lưu điểm thất bại
1. Kiểm tra Firestore security rules
2. Kiểm tra user authentication
3. Kiểm tra dữ liệu điểm hợp lệ (0-10)

### Batch write fail
1. Không vượt quá 500 documents/batch
2. Kiểm tra field names trong Firestore

---

## 📝 Quy Tắc Đặt Tên Firestore

- **Collection**: `sinh_vien`, `diem`, `mon_hoc`
- **Document IDs**: 
  - Sinh viên: `SV001` (maSV)
  - Điểm: `SV001_MH001` (maSV_maMon)
- **Fields**: camelCase hoặc snake_case (nhất quán)

---

**Tác giả**: GitHub Copilot  
**Ngày cập nhật**: 2026-06-05  
**Phiên bản**: v2.0 (Firestore Integration)
