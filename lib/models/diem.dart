
class Diem {
  String maDiem;
  String maSV;
  String maMon;
  int hocKy; // Thêm trường học kỳ để dễ quản lý và truy vấn hơn
  double diemGiuaKy;
  double diemCuoiKy;
  double heSoGiuaKy;
  double heSoCuoiKy;

  Diem({
    required this.maDiem,
    required this.maSV,
    required this.maMon,
    required this.hocKy,
    required this.diemGiuaKy,
    required this.diemCuoiKy,
    required this.heSoGiuaKy,
    required this.heSoCuoiKy,
  });

  /// Tạo Diem từ Firestore document
  factory Diem.fromFirestore(Map<String, dynamic> data) {
    return Diem(
      maDiem: data['maDiem'] ?? '',
      maSV: data['maSV'] ?? '',
      maMon: data['maMon'] ?? '',
      hocKy: data['hocKy'] ?? 0,
      diemGiuaKy: (data['diemGiuaKy'] ?? 0).toDouble(),
      diemCuoiKy: (data['diemCuoiKy'] ?? 0).toDouble(),
      heSoGiuaKy: (data['heSoGiuaKy'] ?? 0.4).toDouble(),
      heSoCuoiKy: (data['heSoCuoiKy'] ?? 0.6).toDouble(),
    );
  }

  /// Chuyển đổi Diem thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'maDiem': maDiem,
      'maSV': maSV,
      'maMon': maMon,
      'hocKy': hocKy,
      'diemGiuaKy': diemGiuaKy,
      'diemCuoiKy': diemCuoiKy,
      'heSoGiuaKy': heSoGiuaKy,
      'heSoCuoiKy': heSoCuoiKy,
    };
  }

  /// Tính điểm trung bình
  double getDTB() {
    if (diemGiuaKy == 0 && diemCuoiKy == 0) return 0;
    return double.parse(
        (diemGiuaKy * heSoGiuaKy + diemCuoiKy * heSoCuoiKy).toStringAsFixed(1));
  }

  /// Tạo đối tượng Diem trống cho sinh viên chưa có điểm
  factory Diem.empty(String maSV, String maMon) {
    return Diem(
      maDiem: '${maSV}_$maMon',
      maSV: maSV,
      maMon: maMon,
      hocKy: 0, // Có thể để trống hoặc gán giá trị mặc định
      diemGiuaKy: 0.0,
      diemCuoiKy: 0.0,
      heSoGiuaKy: 0.4,
      heSoCuoiKy: 0.6,
    );
  }
}


