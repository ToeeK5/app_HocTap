import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tai_khoan.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<TaiKhoan?> dangNhap(String taiKhoan, String matKhau) async {
    final user = taiKhoan.trim();
    final pass = matKhau.trim();

    try {
      final queryTenDangNhap = await _db
          .collection('tai_khoan')
          .where('tenDangNhap', isEqualTo: user)
          .where('matKhau', isEqualTo: pass)
          .limit(1)
          .get();

      if (queryTenDangNhap.docs.isNotEmpty) {
        return _taoTaiKhoanTuFirestore(queryTenDangNhap.docs.first.data());
      }

      final queryMaSV = await _db
          .collection('tai_khoan')
          .where('maSV', isEqualTo: user)
          .where('matKhau', isEqualTo: pass)
          .limit(1)
          .get();

      if (queryMaSV.docs.isNotEmpty) {
        return _taoTaiKhoanTuFirestore(queryMaSV.docs.first.data());
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  bool laAdmin(TaiKhoan tk) {
    return tk.vaiTro.toLowerCase().trim() == 'admin';
  }

  Future<TaiKhoan?> kiemTraQuenMatKhau(String taiKhoan, String email) async {
    final user = taiKhoan.trim();
    final mail = email.trim().toLowerCase();

    try {
      QuerySnapshot<Map<String, dynamic>> queryTK = await _db
          .collection('tai_khoan')
          .where('tenDangNhap', isEqualTo: user)
          .limit(1)
          .get();

      if (queryTK.docs.isEmpty) {
        queryTK = await _db
            .collection('tai_khoan')
            .where('maSV', isEqualTo: user)
            .limit(1)
            .get();
      }

      if (queryTK.docs.isEmpty) {
        return null;
      }

      final tk = _taoTaiKhoanTuFirestore(queryTK.docs.first.data());

      final querySV = await _db
          .collection('sinh_vien')
          .where('maSV', isEqualTo: tk.maSV)
          .limit(1)
          .get();

      if (querySV.docs.isEmpty) {
        return null;
      }

      final svData = querySV.docs.first.data();
      final emailSV = (svData['email'] ?? '').toString().trim().toLowerCase();

      if (emailSV == mail) {
        return tk;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> doiMatKhau(String maTK, String matKhauMoi) async {
    try {
      final queryTK = await _db
          .collection('tai_khoan')
          .where('maTK', isEqualTo: maTK.trim())
          .limit(1)
          .get();

      if (queryTK.docs.isEmpty) {
        return false;
      }

      await _db.collection('tai_khoan').doc(queryTK.docs.first.id).update({
        'matKhau': matKhauMoi.trim(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  TaiKhoan _taoTaiKhoanTuFirestore(Map<String, dynamic> data) {
    return TaiKhoan(
      maTK: (data['maTK'] ?? '').toString(),
      maSV: (data['maSV'] ?? '').toString(),
      tenDangNhap: (data['tenDangNhap'] ?? '').toString(),
      matKhau: (data['matKhau'] ?? '').toString(),
      vaiTro: (data['vaiTro'] ?? '').toString(),
    );
  }
}