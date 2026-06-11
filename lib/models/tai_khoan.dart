class TaiKhoan {
  String maTK;
  String maSV;
  String tenDangNhap;
  String matKhau;
  String vaiTro;

  TaiKhoan({
    required this.maTK,
    required this.maSV,
    required this.tenDangNhap,
    required this.matKhau,
    required this.vaiTro,
  });

  factory TaiKhoan.fromFirestore(Map<String, dynamic> data) {
    return TaiKhoan(
      maTK: data['maTK'] ?? '',
      maSV: data['maSV'] ?? '',
      tenDangNhap: data['tenDangNhap'] ?? '',
      matKhau: data['matKhau'] ?? '',
      vaiTro: data['vaiTro'] ?? 'sinhvien',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maTK': maTK,
      'maSV': maSV,
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'vaiTro': vaiTro,
    };
  }
}
