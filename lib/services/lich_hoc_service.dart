import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ke_hoach_on_tap.dart';
import '../models/lich_hoc.dart';
import '../models/mon_hoc.dart';
import 'dang_ky_service.dart';

// This service now reads MonHoc from Firestore instead of AppData

class LichHocHienThi {
  final LichHoc lichHoc;
  final MonHoc monHoc;

  LichHocHienThi({required this.lichHoc, required this.monHoc});
}

class LichHocService {
  // Lấy lịch cho sinh viên (từ các môn đã đăng ký) — wrapper để duy trì API
  Future<List<LichHocHienThi>> layLichTheoSinhVien(String maSV) async {
    return layLichThucTeTheoSinhVien(maSV);
  }

  Future<List<LichHocHienThi>> layLichTheoHocKy(String maSV, int hocKy) async {
    final all = await layLichTheoSinhVien(maSV);
    return all.where((item) => item.monHoc.hocKy == hocKy).toList();
  }

  Future<List<LichHocHienThi>> layLichHomNay(String maSV) async {
    final thuHomNay = tenThu(DateTime.now().weekday);
    final all = await layLichTheoSinhVien(maSV);
    return all.where((item) => item.lichHoc.thu == thuHomNay).toList();
  }

  List<KeHoachOnTap> layKeHoachTheoSinhVien(String maSV) {
    // keep existing AppData-backed plans for now
    // TODO: migrate KeHoach to Firestore if needed
    return <KeHoachOnTap>[];
  }

  List<LichHocHienThi> sapXepLich(List<LichHocHienThi> danhSach) {
    final ketQua = [...danhSach];
    ketQua.sort((a, b) {
      final thu = thuTuThu(a.lichHoc.thu).compareTo(thuTuThu(b.lichHoc.thu));
      if (thu != 0) return thu;
      return _phutTrongNgay(
        a.lichHoc.gioBatDau,
      ).compareTo(_phutTrongNgay(b.lichHoc.gioBatDau));
    });
    return ketQua;
  }

  // Lấy MonHoc trực tiếp từ Firestore
  Future<MonHoc?> timMonHocTheoMa(String maMon) async {
    try {
      final db = FirebaseFirestore.instance;
      // Try matching by field 'maMon' first
      final snap = await db
          .collection('mon_hoc')
          .where('maMon', isEqualTo: maMon)
          .get();
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        return MonHoc(
          maMon: data['maMon'] ?? snap.docs.first.id,
          tenMon: data['tenMon'] ?? '',
          soTinChi: (data['soTinChi'] is int)
              ? data['soTinChi'] as int
              : int.tryParse('${data['soTinChi']}') ?? 0,
          hocKy: (data['hocKy'] is int)
              ? data['hocKy'] as int
              : int.tryParse('${data['hocKy']}') ?? 1,
        );
      }

      // Fallback: try document id
      final doc = await db.collection('mon_hoc').doc(maMon).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        return MonHoc(
          maMon: data['maMon'] ?? doc.id,
          tenMon: data['tenMon'] ?? '',
          soTinChi: (data['soTinChi'] is int)
              ? data['soTinChi'] as int
              : int.tryParse('${data['soTinChi']}') ?? 0,
          hocKy: (data['hocKy'] is int)
              ? data['hocKy'] as int
              : int.tryParse('${data['hocKy']}') ?? 1,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy lịch thực tế của các môn mà sinh viên đã đăng ký (từ Firestore)
  Future<List<LichHocHienThi>> layLichThucTeTheoSinhVien(String maSV) async {
    final dkService = DangKyService();
    final maMons = await dkService.layMonDaDangKyTatCa(maSV);
    if (maMons.isEmpty) return [];

    // fetch lich_hoc documents in chunks via existing DangKyService helper
    final lichDocs = await dkService.layLichTheoMaMon(maMons);

    final ketQua = <LichHocHienThi>[];
    for (final d in lichDocs) {
      final maMon = d['maMon'] ?? '';
      final monHoc = await timMonHocTheoMa(maMon);
      if (monHoc == null) continue;

      // build LichHoc model
      final lich = LichHoc(
        maLich: d['id'] ?? '',
        maSV: d['maSV'] ?? '',
        maMon: maMon,
        thu: d['thu'] ?? '',
        gioBatDau: d['gioBatDau'] ?? '',
        gioKetThuc: d['gioKetThuc'] ?? '',
        phongHoc: d['phongHoc'] ?? '',
      );

      ketQua.add(LichHocHienThi(lichHoc: lich, monHoc: monHoc));
    }

    return sapXepLich(ketQua);
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
