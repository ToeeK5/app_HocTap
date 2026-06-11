import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_data.dart';
import '../models/tai_khoan.dart';

class AuthService {
  // NOTE FIREBASE:
  // Sau nay doi AppData thanh FirebaseAuth hoac Firestore collection TAIKHOAN.

  TaiKhoan? dangNhap(String taiKhoan, String matKhau) {
    final user = taiKhoan.trim();
    final pass = matKhau.trim();

    try {
      return AppData.danhSachTaiKhoan.firstWhere(
        (tk) =>
            (tk.tenDangNhap.trim() == user || tk.maSV.trim() == user) &&
            tk.matKhau.trim() == pass,
      );
    } catch (e) {
      return null;
    }
  }

  /// Firestore-backed async login
  Future<TaiKhoan?> dangNhapAsync(String taiKhoan, String matKhau) async {
    final user = taiKhoan.trim();
    final pass = matKhau.trim();
    try {
      final db = FirebaseFirestore.instance;
      // Try to find by tenDangNhap or maSV and matching password
      final q1 = await db
          .collection('tai_khoan')
          .where('tenDangNhap', isEqualTo: user)
          .where('matKhau', isEqualTo: pass)
          .limit(1)
          .get();
      if (q1.docs.isNotEmpty)
        return TaiKhoan.fromFirestore(q1.docs.first.data());
      final q2 = await db
          .collection('tai_khoan')
          .where('maSV', isEqualTo: user)
          .where('matKhau', isEqualTo: pass)
          .limit(1)
          .get();
      if (q2.docs.isNotEmpty)
        return TaiKhoan.fromFirestore(q2.docs.first.data());
      return null;
    } catch (e) {
      return null;
    }
  }

  bool laAdmin(TaiKhoan tk) {
    return tk.vaiTro.toLowerCase().trim() == "admin";
  }

  TaiKhoan? kiemTraQuenMatKhau(String taiKhoan, String email) {
    final user = taiKhoan.trim();
    final mail = email.trim().toLowerCase();

    try {
      final tk = AppData.danhSachTaiKhoan.firstWhere(
        (x) => x.tenDangNhap.trim() == user || x.maSV.trim() == user,
      );

      final sv = AppData.danhSachSinhVien.firstWhere(
        (x) => x.maSV.trim() == tk.maSV.trim(),
      );

      if (sv.email.trim().toLowerCase() == mail) {
        return tk;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  bool doiMatKhau(String maTK, String matKhauMoi) {
    try {
      final tk = AppData.danhSachTaiKhoan.firstWhere(
        (x) => x.maTK.trim() == maTK.trim(),
      );

      tk.matKhau = matKhauMoi.trim();
      return true;
    } catch (e) {
      return false;
    }
  }
}
