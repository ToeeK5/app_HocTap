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
          hocKyMon: data["hocKyMon"] ?? 1,
          hocKySinhVien: data["hocKySinhVien"] ?? 1,
          diemGiuaKy: (data["diemGiuaKy"] ?? 0).toDouble(),
          diemCuoiKy: (data["diemCuoiKy"] ?? 0).toDouble(),
          heSoGiuaKy: (data["heSoGiuaKy"] ?? 0.4).toDouble(),
          heSoCuoiKy: (data["heSoCuoiKy"] ?? 0.6).toDouble(),
        );

        final monHoc = await timMonHocTheoMa(diem.maMon);
        final hocKy = await timHocKyTheoMa(diem.hocKyMon);

        if (monHoc != null) {
          dsKetQua.add(
            DiemMonHienThi(
              diem: diem,
              monHoc: monHoc,
              hocKy: hocKy ?? HocKy(id: diem.hocKyMon.toString(), tenHocKy: "Học kỳ ${diem.hocKyMon}", value: diem.hocKyMon),
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
      // Đổi từ .doc(maMon) sang .where("maMon", isEqualTo: maMon)
      final snap = await _db.collection("mon_hoc").where("maMon", isEqualTo: maMon).get();
      if (snap.docs.isEmpty) return null;
      
      final data = snap.docs.first.data();
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
      // Tìm tài liệu có trường value hoặc id tương ứng thay vì ép ID Document
      final snap = await _db.collection("hoc_ky").where("value", isEqualTo: maHocKy).get();
      if (snap.docs.isEmpty) return null;

      final data = snap.docs.first.data();
      return HocKy(
        id: data["ID"] ?? snap.docs.first.id, // Lưu ý hoa/thường chữ 'id' hay 'ID' của bạn trên DB
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