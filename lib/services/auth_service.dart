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
