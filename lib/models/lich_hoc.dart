class LichHoc {
  String maLich;
  String maSV;
  String maMon;
  String thu;
  String gioBatDau;
  String gioKetThuc;
  String phongHoc;

  LichHoc({
    required this.maLich,
    required this.maSV,
    required this.maMon,
    required this.thu,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.phongHoc,
  });

  factory LichHoc.fromMap(Map<String, dynamic> data) => LichHoc(
        maLich: data['maLich'] as String,
        maSV: data['maSV'] as String,
        maMon: data['maMon'] as String,
        thu: data['thu'] as String,
        gioBatDau: data['gioBatDau'] as String,
        gioKetThuc: data['gioKetThuc'] as String,
        phongHoc: data['phongHoc'] as String,
      );

  Map<String, dynamic> toMap() => {
        'maLich': maLich,
        'maSV': maSV,
        'maMon': maMon,
        'thu': thu,
        'gioBatDau': gioBatDau,
        'gioKetThuc': gioKetThuc,
        'phongHoc': phongHoc,
      };
}
