
class SinhVien {
  String maSV;
  String hoTen;
  String email;
  int namSinh;
  String lop;
  int hocKyHienTai;
  String? sdt;

  SinhVien({
    required this.maSV,
    required this.hoTen,
    required this.email,
    required this.namSinh,
    required this.lop,
    required this.hocKyHienTai,
    this.sdt,
  });

  /// Tạo SinhVien từ Firestore document
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

  /// Chuyển đổi SinhVien thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'maSV': maSV,
      'hoTen': hoTen,
      'email': email,
      'namSinh': namSinh,
      'lop': lop,
      'hocKyHienTai': hocKyHienTai,
      'sdt': sdt,
    };
  }
}


