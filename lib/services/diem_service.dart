import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_data.dart';
import '../models/diem.dart';
import '../models/mon_hoc.dart';

class DiemMonHienThi {
  final Diem diem;
  final MonHoc monHoc;
  final double diemTongKet;

  DiemMonHienThi({
    required this.diem,
    required this.monHoc,
    required this.diemTongKet,
  });
}

class DiemService {
  // NOTE FIREBASE:
  // Sau nay doi AppData thanh Firestore collection DIEM va MONHOC.
  List<DiemMonHienThi> layDiemTheoSinhVien(String maSV) {
    final dsDiem = AppData.danhSachDiem.where((d) => d.maSV == maSV).toList();

    final ketQua = <DiemMonHienThi>[];
    for (final d in dsDiem) {
      final mon = timMonHocTheoMa(d.maMon);
      if (mon == null) continue;
      ketQua.add(
        DiemMonHienThi(diem: d, monHoc: mon, diemTongKet: tinhDiemTongKet(d)),
      );
    }

    return ketQua;
  }

  double tinhDiemTongKet(Diem d) {
    final tongHeSo = d.heSoGiuaKy + d.heSoCuoiKy;
    if (tongHeSo == 0) return 0;
    final diem =
        (d.diemGiuaKy * d.heSoGiuaKy + d.diemCuoiKy * d.heSoCuoiKy) / tongHeSo;
    return diem.clamp(0, 10).toDouble();
  }

  MonHoc? timMonHocTheoMa(String maMon) {
    try {
      return AppData.danhSachMonHoc.firstWhere((m) => m.maMon == maMon);
    } catch (e) {
      return null;
    }
  }
}

// Firestore-backed API

extension DiemServiceFirestore on DiemService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<List<DiemMonHienThi>> layDiemTheoSinhVienAsync(String maSV) async {
    try {
      final query = await _db
          .collection('diem')
          .where('maSV', isEqualTo: maSV)
          .get();
      final List<DiemMonHienThi> ketQua = [];
      for (var doc in query.docs) {
        final data = doc.data();
        final diem = Diem.fromFirestore(data);
        // fetch monhoc
        final monDoc = await _db.collection('mon_hoc').doc(diem.maMon).get();
        if (!monDoc.exists) continue;
        final mon = MonHoc.fromMap(monDoc.data() as Map<String, dynamic>);
        ketQua.add(
          DiemMonHienThi(
            diem: diem,
            monHoc: mon,
            diemTongKet: tinhDiemTongKet(diem),
          ),
        );
      }
      return ketQua;
    } catch (e) {
      return [];
    }
  }
}
