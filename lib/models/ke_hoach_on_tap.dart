class KeHoachOnTap {
  String maKeHoach;
  String maSV;

  String tieuDe;
  String noiDung;

  String ngayOnTap;
  String trangThai;

  KeHoachOnTap({
    required this.maKeHoach,
    required this.maSV,

    required this.tieuDe,
    required this.noiDung,

    required this.ngayOnTap,
    required this.trangThai,
  });

  // Firestore mapping
  factory KeHoachOnTap.fromMap(Map<String, dynamic> data) => KeHoachOnTap(
    maKeHoach: data['maKeHoach'] as String,
    maSV: data['maSV'] as String,
    tieuDe: data['tieuDe'] as String,
    noiDung: data['noiDung'] as String,
    ngayOnTap: data['ngayOnTap'] as String,
    trangThai: data['trangThai'] as String,
  );

  Map<String, dynamic> toMap() => {
    'maKeHoach': maKeHoach,
    'maSV': maSV,
    'tieuDe': tieuDe,
    'noiDung': noiDung,
    'ngayOnTap': ngayOnTap,
    'trangThai': trangThai,
  };
}
