class MonHoc {
  String maMon;
  String tenMon;
  int soTinChi;
  int hocKy;
  String? giangVien;

  MonHoc({
    required this.maMon,
    required this.tenMon,
    required this.soTinChi,
    required this.hocKy,
    this.giangVien,
  });

  // Firestore mapping
  factory MonHoc.fromMap(Map<String, dynamic> data) => MonHoc(
    maMon: (data['maMon'] ?? data['maMH'] ?? '') as String,
    tenMon: (data['tenMon'] ?? '') as String,
    soTinChi: (data['soTinChi'] ?? 0) as int,
    hocKy: (data['hocKy'] ?? 1) as int,
    giangVien: data['giangVien'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'maMon': maMon,
    'tenMon': tenMon,
    'soTinChi': soTinChi,
    'hocKy': hocKy,
    'giangVien': giangVien,
  };
}
