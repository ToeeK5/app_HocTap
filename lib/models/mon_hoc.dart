class MonHoc {
  String maMon;
  String tenMon;
  int soTinChi;
  int hocKy;

  MonHoc({
    required this.maMon,
    required this.tenMon,
    required this.soTinChi,
    required this.hocKy,
  });

  // Firestore mapping
  factory MonHoc.fromMap(Map<String, dynamic> data) => MonHoc(
    maMon: data['maMon'] as String,
    tenMon: data['tenMon'] as String,
    soTinChi: data['soTinChi'] as int,
    hocKy: data['hocKy'] as int,
  );

  Map<String, dynamic> toMap() => {
    'maMon': maMon,
    'tenMon': tenMon,
    'soTinChi': soTinChi,
    'hocKy': hocKy,
  };
}
