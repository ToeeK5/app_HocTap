import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diem.dart';
import '../models/mon_hoc.dart';
import 'package:app_hoctap/models/hoc_ki.dart';

class DiemMonHienThi {
  final Diem diem;
  final MonHoc monHoc;
  final HocKy hocKy;  
  final double diemTongKet;

  DiemMonHienThi({
    required this.diem,
    required this.monHoc,
    required this.hocKy,
    required this.diemTongKet,
  });
}

class DiemService {
  final _db = FirebaseFirestore.instance;

  Future<List<DiemMonHienThi>> layDiemTheoSinhVien(String maSV) async {
    final dsKetQua = <DiemMonHienThi>[];

    try {
      final diemSnap = await _db
          .collection("diem")
          .where("maSV", isEqualTo: maSV)
          .get();

      for (final doc in diemSnap.docs) {
        final data = doc.data();

        final diem = Diem(
          maDiem: data["maDiem"] ?? doc.id,
          maSV: data["maSV"] ?? "",
          maMon: data["maMon"] ?? "",
          hocKy: data["hocKy"] ?? 1,
          diemGiuaKy: (data["diemGiuaKy"] ?? 0).toDouble(),
          diemCuoiKy: (data["diemCuoiKy"] ?? 0).toDouble(),
          heSoGiuaKy: (data["heSoGiuaKy"] ?? 0.4).toDouble(),
          heSoCuoiKy: (data["heSoCuoiKy"] ?? 0.6).toDouble(),
        );

        final monHoc = await timMonHocTheoMa(diem.maMon);
        final hocKy = await timHocKyTheoMa(diem.hocKy);

        if (monHoc != null) {
          dsKetQua.add(
            DiemMonHienThi(
              diem: diem,
              monHoc: monHoc,
              hocKy: hocKy ?? HocKy(id: diem.hocKy.toString(), tenHocKy: "Học kỳ ${diem.hocKy}", value: diem.hocKy),
              diemTongKet: tinhDiemTongKet(diem),
            ),
          );
        }
      }

      return dsKetQua;
    } catch (e) {
      return [];
    }
  }

  Future<MonHoc?> timMonHocTheoMa(String maMon) async {
    try {
      final doc = await _db.collection("mon_hoc").doc(maMon).get();

      if (!doc.exists) return null;

      final data = doc.data()!;

      return MonHoc(
        maMon: data["maMon"] ?? "",
        tenMon: data["tenMon"] ?? "",
        soTinChi: data["soTinChi"] ?? 0,
        hocKy: data["hocKy"] ?? 1,
      );
    } catch (e) {
      return null;
    }
  }

  Future<HocKy?> timHocKyTheoMa(int maHocKy) async {
    try {
      final doc = await _db.collection("hoc_ky").doc(maHocKy.toString()).get();

      if (!doc.exists) return null;

      final data = doc.data()!;

      return HocKy(
        id: data["ID"] ?? "",
        tenHocKy: data["tenHocKy"] ?? "",
        value: data["value"] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  double tinhDiemTongKet(Diem d) {
    final tongHeSo = d.heSoGiuaKy + d.heSoCuoiKy;
    if (tongHeSo == 0) return 0;

    final diem =
        (d.diemGiuaKy * d.heSoGiuaKy + d.diemCuoiKy * d.heSoCuoiKy) /
            tongHeSo;

    return diem.clamp(0, 10).toDouble();
  }
}