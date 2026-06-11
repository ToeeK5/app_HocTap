import '../data/app_data.dart';
import '../models/sinh_vien.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SinhVienService {
  // NOTE FIREBASE:
  // Sau nay doi thanh query collection SINHVIEN where maSV.
  SinhVien? laySinhVienTheoMa(String maSV) {
    try {
      return AppData.danhSachSinhVien.firstWhere((sv) => sv.maSV == maSV);
    } catch (e) {
      return null;
    }
  }

  Future<SinhVien?> laySinhVienTheoMaAsync(String maSV) async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('sinh_vien').doc(maSV).get();
      if (!doc.exists || doc.data() == null) return null;
      return SinhVien.fromFirestore(doc.data()!);
    } catch (e) {
      return null;
    }
  }
}
