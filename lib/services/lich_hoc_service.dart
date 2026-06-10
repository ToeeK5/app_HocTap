import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lich_hoc.dart';
import '../models/mon_hoc.dart';
import '../models/ke_hoach_on_tap.dart';

class LichHocHienThi {
  final LichHoc lichHoc;
  final MonHoc monHoc;

  LichHocHienThi({required this.lichHoc, required this.monHoc});
}

class LichHocService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch schedule for a student (async)
  Future<List<LichHocHienThi>> layLichTheoSinhVien(String maSV) async {
    final query = await _db
        .collection('lich_hoc')
        .where('maSV', isEqualTo: maSV)
        .get();
    final docs = query.docs;
    if (docs.isEmpty) return [];

    // Parse LichHoc objects and collect distinct maMon ids
    final lichList = <LichHoc>[];
    final maMonSet = <String>{};
    for (var doc in docs) {
      final data = doc.data();
      final lich = LichHoc.fromMap(data);
      lichList.add(lich);
      maMonSet.add(lich.maMon);
    }

    // Batch fetch MonHoc documents using whereIn to avoid N+1 reads
    final maMonList = maMonSet.toList();
    final Map<String, MonHoc> monMap = {};
    if (maMonList.isNotEmpty) {
      // Firestore whereIn has a limit; if too many, fetch in chunks
      const int chunkSize = 10;
      for (var i = 0; i < maMonList.length; i += chunkSize) {
        final chunk = maMonList.sublist(
          i,
          (i + chunkSize) > maMonList.length ? maMonList.length : i + chunkSize,
        );
        final monQuery = await _db
            .collection('mon_hoc')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (var d in monQuery.docs) {
          final data = d.data();
          try {
            monMap[d.id] = MonHoc.fromMap(data);
          } catch (_) {
            // ignore malformed
          }
        }
      }
    }

    final result = <LichHocHienThi>[];
    for (var lich in lichList) {
      final mon = monMap[lich.maMon];
      if (mon != null) {
        result.add(LichHocHienThi(lichHoc: lich, monHoc: mon));
      } else {
        // fallback: try to read single doc (if it wasn't fetched)
        final monDoc = await _db.collection('mon_hoc').doc(lich.maMon).get();
        if (monDoc.exists) {
          final monObj = MonHoc.fromMap(monDoc.data()!);
          result.add(LichHocHienThi(lichHoc: lich, monHoc: monObj));
        }
      }
    }

    return sapXepLich(result);
  }

  Future<List<LichHocHienThi>> layLichTheoHocKy(String maSV, int hocKy) async {
    final all = await layLichTheoSinhVien(maSV);
    return all.where((item) => item.monHoc.hocKy == hocKy).toList();
  }

  Future<List<LichHocHienThi>> layLichHomNay(String maSV) async {
    final all = await layLichTheoSinhVien(maSV);
    final thuHomNay = tenThu(DateTime.now().weekday);
    return all.where((item) => item.lichHoc.thu == thuHomNay).toList();
  }

  Future<List<KeHoachOnTap>> layKeHoachTheoSinhVien(String maSV) async {
    final query = await _db
        .collection('ke_hoach')
        .where('maSV', isEqualTo: maSV)
        .get();
    return query.docs.map((doc) => KeHoachOnTap.fromMap(doc.data())).toList();
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

  MonHoc? timMonHocTheoMa(String maMon) => null; // Not used with Firestore

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
