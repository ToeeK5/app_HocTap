import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../utils/theme_app.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() {
    return _ResetPasswordScreenState();
  }
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool hienMK = false;

  final matKhauMoiController = TextEditingController();
  final xacNhanController = TextEditingController();
  final authService = AuthService();

  @override
  void dispose() {
    matKhauMoiController.dispose();
    xacNhanController.dispose();
    super.dispose();
  }

  InputDecoration oNhap(String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.lock_rounded, color: ThemeApp.mauChinh),
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            hienMK = !hienMK;
          });
        },
        icon: Icon(
          hienMK ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: ThemeApp.chuPhu,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  void doiMatKhau() async {
  final maTK = SessionService.maTKDoiMatKhau;

  if (maTK == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Khong tim thay tai khoan")),
    );

    Navigator.pop(context);
    return;
  }

  final mk = matKhauMoiController.text.trim();
  final xacNhan = xacNhanController.text.trim();

  if (mk.isEmpty || xacNhan.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui long nhap day du mat khau")),
    );
    return;
  }

  if (mk.length < 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mat khau phai tu 3 ky tu")),
    );
    return;
  }

  if (mk != xacNhan) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mat khau xac nhan khong khop")),
    );
    return;
  }

  final ok = await authService.doiMatKhau(maTK, mk);

  if (!mounted) return;

  if (ok) {
    SessionService.xoaMaTKDoiMatKhau();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Doi mat khau thanh cong")),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Doi mat khau that bai")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.mauNen,
      appBar: AppBar(
        title: const Text("Doi mat khau"),
        backgroundColor: ThemeApp.mauNen,
        foregroundColor: ThemeApp.chuDam,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ThemeApp.mauPhu,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.password_rounded,
                  size: 55,
                  color: ThemeApp.mauIcon,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Tao mat khau moi",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.chuDam,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Nhap va xac nhan lai mat khau moi",
                style: TextStyle(color: ThemeApp.chuPhu),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: matKhauMoiController,
                obscureText: !hienMK,
                decoration: oNhap("Nhap mat khau moi"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: xacNhanController,
                obscureText: !hienMK,
                decoration: oNhap("Xac nhan mat khau"),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: doiMatKhau,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeApp.mauChinh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "LUU MAT KHAU",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
