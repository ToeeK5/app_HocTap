import '../data/app_data.dart';
import '../models/ke_hoach_on_tap.dart';
import '../models/lich_hoc.dart';
import '../models/mon_hoc.dart';

class LichHocHienThi {
  final LichHoc lichHoc;
  final MonHoc monHoc;

  LichHocHienThi({
    required this.lichHoc,
    required this.monHoc,
  });
}

class LichHocService {
  List<LichHocHienThi> layLichTheoSinhVien(String maSV) {
    final ketQua = <LichHocHienThi>[];
    final dsLich = AppData.danhSachLichHoc.where((lich) => lich.maSV == maSV);

    for (final lich in dsLich) {
      final monHoc = timMonHocTheoMa(lich.maMon);
      if (monHoc == null) continue;
      ketQua.add(LichHocHienThi(lichHoc: lich, monHoc: monHoc));
    }

    return sapXepLich(ketQua);
  }

  List<LichHocHienThi> layLichTheoHocKy(String maSV, int hocKy) {
    return layLichTheoSinhVien(maSV)
        .where((item) => item.monHoc.hocKy == hocKy)
        .toList();
  }

  List<LichHocHienThi> layLichHomNay(String maSV) {
    final thuHomNay = tenThu(DateTime.now().weekday);
    return layLichTheoSinhVien(maSV)
        .where((item) => item.lichHoc.thu == thuHomNay)
        .toList();
  }

  List<KeHoachOnTap> layKeHoachTheoSinhVien(String maSV) {
    return AppData.danhSachKeHoach
        .where((keHoach) => keHoach.maSV == maSV)
        .toList();
  }

  List<LichHocHienThi> sapXepLich(List<LichHocHienThi> danhSach) {
    final ketQua = [...danhSach];
    ketQua.sort((a, b) {
      final thu = thuTuThu(a.lichHoc.thu).compareTo(thuTuThu(b.lichHoc.thu));
      if (thu != 0) return thu;
      return _phutTrongNgay(a.lichHoc.gioBatDau).compareTo(
        _phutTrongNgay(b.lichHoc.gioBatDau),
      );
    });
    return ketQua;
  }

  MonHoc? timMonHocTheoMa(String maMon) {
    try {
      return AppData.danhSachMonHoc.firstWhere((mon) => mon.maMon == maMon);
    } catch (e) {
      return null;
    }
  }

  int thuTuThu(String thu) {
    final giaTri = thu.trim().toLowerCase();
    if (giaTri == 'thứ 2') return 2;
    if (giaTri == 'thứ 3') return 3;
    if (giaTri == 'thứ 4') return 4;
    if (giaTri == 'thứ 5') return 5;
    if (giaTri == 'thứ 6') return 6;
    if (giaTri == 'thứ 7') return 7;
    if (giaTri == 'chủ nhật') return 8;
    return 99;
  }

  String tenThu(int weekday) {
    if (weekday == DateTime.sunday) return 'Chủ nhật';
    return 'Thứ ${weekday + 1}';
  }

  int _phutTrongNgay(String gio) {
    final parts = gio.split(':');
    if (parts.length != 2) return 0;

    final gioTrongNgay = int.tryParse(parts[0]) ?? 0;
    final phut = int.tryParse(parts[1]) ?? 0;
    return gioTrongNgay * 60 + phut;
  }
}
