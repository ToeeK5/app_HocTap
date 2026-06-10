import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_data.dart';

class DayDuLieuFirestoreService {
  final db = FirebaseFirestore.instance;

  Future<void> dayTatCaDuLieuLenFirestore() async {
    final batch = db.batch();

    for (final sv in AppData.danhSachSinhVien) {
      batch.set(db.collection('sinh_vien').doc(sv.maSV), {
        'maSV': sv.maSV,
        'hoTen': sv.hoTen,
        'email': sv.email,
        'namSinh': sv.namSinh,
        'lop': sv.lop,
        'hocKyHienTai': sv.hocKyHienTai,
      });
    }

    for (final tk in AppData.danhSachTaiKhoan) {
      batch.set(db.collection('tai_khoan').doc(tk.maTK), {
        'maTK': tk.maTK,
        'maSV': tk.maSV,
        'tenDangNhap': tk.tenDangNhap,
        'matKhau': tk.matKhau,
        'vaiTro': tk.vaiTro,
      });
    }

    for (final mon in AppData.danhSachMonHoc) {
      batch.set(db.collection('mon_hoc').doc(mon.maMon), {
        'maMon': mon.maMon,
        'tenMon': mon.tenMon,
        'soTinChi': mon.soTinChi,
        'hocKy': mon.hocKy,
      });
    }

    for (final d in AppData.danhSachDiem) {
      batch.set(db.collection('diem').doc('${d.maSV}_${d.maMon}'), {
        'maDiem': d.maDiem,
        'maSV': d.maSV,
        'maMon': d.maMon,
        'diemGiuaKy': d.diemGiuaKy,
        'diemCuoiKy': d.diemCuoiKy,
        'heSoGiuaKy': d.heSoGiuaKy,
        'heSoCuoiKy': d.heSoCuoiKy,
      });
    }

    for (final lich in AppData.danhSachLichHoc) {
      batch.set(db.collection('lich_hoc').doc(lich.maLich), {
        'maLich': lich.maLich,
        'maSV': lich.maSV,
        'maMon': lich.maMon,
        'thu': lich.thu,
        'gioBatDau': lich.gioBatDau,
        'gioKetThuc': lich.gioKetThuc,
        'phongHoc': lich.phongHoc,
      });
    }

    for (final kh in AppData.danhSachKeHoach) {
      batch.set(db.collection('ke_hoach_on_tap').doc(kh.maKeHoach), {
        'maKeHoach': kh.maKeHoach,
        'maSV': kh.maSV,
        'tieuDe': kh.tieuDe,
        'noiDung': kh.noiDung,
        'ngayOnTap': kh.ngayOnTap,
        'trangThai': kh.trangThai,
      });
    }
    

    await batch.commit();
  }
  Future<void> themDiemDayDuChoTatCaSinhVien() async {
  final batch = db.batch();

  final danhSachMaSV = [
    '20120001','20120002','20120003','20120004','20120005',
    '20120006','20120007','20120008','20120009','20120010',
    '20120011','20120012','20120013','20120014','20120015',
    '20120016','20120017','20120018','20120019','20120020',
  ];

  final danhSachMon = ['MH001', 'MH002', 'MH003', 'MH004'];

  int dem = 1;

  for (final maSV in danhSachMaSV) {
    for (final maMon in danhSachMon) {
      final diemGK = 5 + (dem % 5);
      final diemCK = 5.5 + (dem % 4);

      batch.set(db.collection('diem').doc('${maSV}_$maMon'), {
        'maDiem': 'D${dem.toString().padLeft(3, '0')}',
        'maSV': maSV,
        'maMon': maMon,
        'diemGiuaKy': diemGK,
        'diemCuoiKy': diemCK,
        'heSoGiuaKy': 0.4,
        'heSoCuoiKy': 0.6,
      });

      dem++;
    }
  }

  await batch.commit();
}
  Future<void> themDiemChoTatCaSinhVien() async {
  final batch = db.batch();

  final danhSachMaSV = [
    '20120001',
    '20120002',
    '20120003',
    '20120004',
    '20120005',
    '20120006',
    '20120007',
    '20120008',
    '20120009',
    '20120010',
    '20120011',
    '20120012',
    '20120013',
    '20120014',
    '20120015',
    '20120016',
    '20120017',
    '20120018',
    '20120019',
    '20120020',
  ];

  final danhSachMon = ['MH002', 'MH003', 'MH004'];

  int dem = 100;

  for (final maSV in danhSachMaSV) {
    for (final maMon in danhSachMon) {
      dem++;

      batch.set(db.collection('diem').doc('${maSV}_$maMon'), {
        'maDiem': 'D$dem',
        'maSV': maSV,
        'maMon': maMon,
        'diemGiuaKy': 6 + (dem % 4),
        'diemCuoiKy': 6.5 + (dem % 3),
        'heSoGiuaKy': 0.4,
        'heSoCuoiKy': 0.6,
      });
    }
  }

  await batch.commit();
}
}