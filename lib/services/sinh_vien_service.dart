import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sinh_vien.dart';

class SinhVienService {
  final _db = FirebaseFirestore.instance;

  Future<SinhVien?> laySinhVienTheoMa(String maSV) async {
    try {
      final doc = await _db.collection("sinh_vien").doc(maSV).get();

      if (!doc.exists) return null;

      final data = doc.data()!;

      return SinhVien(
        maSV: data["maSV"] ?? "",
        hoTen: data["hoTen"] ?? "",
        email: data["email"] ?? "",
        namSinh: data["namSinh"] ?? 2000,
        lop: data["lop"] ?? "",
        hocKyHienTai: data["hocKyHienTai"] ?? 1,
      );
    } catch (e) {
      return null;
    }
  }
}