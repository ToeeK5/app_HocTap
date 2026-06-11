import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/session_service.dart';
import '../services/sinh_vien_service.dart';
import '../services/diem_service.dart';
import '../utils/tinh_toan_hoc_tap.dart';
import '../utils/theme_app.dart';
import '../widgets/bottom_nav_app.dart';
import '../widgets/stat_card.dart';
import '../widgets/bieu_do_diem.dart';
import '../utils/mau_hoc_tap.dart';
import '../models/sinh_vien.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dangTron = true;

  @override
  Widget build(BuildContext context) {
    final maSV = SessionService.layMaSV();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        SinhVienService().laySinhVienTheoMaAsync(maSV),
        DiemService().layDiemTheoSinhVienAsync(maSV),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            backgroundColor: ThemeApp.mauNen,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Trang cá nhân"),
              backgroundColor: ThemeApp.mauNen,
              foregroundColor: ThemeApp.chuDam,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: const BottomNavApp(currentIndex: 3),
          );
        }

        final sinhVien = snap.data![0] as SinhVien?;
        final dsDiem = snap.data![1] as List<DiemMonHienThi>;
        final gpa10 = TinhToanHocTap.tinhGPAHe10(dsDiem);
        final gpa4 = TinhToanHocTap.tinhGPAHe4(gpa10);
        final tongTin = TinhToanHocTap.tinhTongTin(dsDiem);
        final xepLoai = TinhToanHocTap.xepLoaiHocLuc(gpa10);

        return Scaffold(
          backgroundColor: ThemeApp.mauNen,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Trang cá nhân"),
            backgroundColor: ThemeApp.mauNen,
            foregroundColor: ThemeApp.chuDam,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: ThemeApp.mauPhu,
                    child: Icon(
                      Icons.person_rounded,
                      size: 58,
                      color: ThemeApp.mauIcon,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sinhVien?.hoTen ?? "Sinh viên",
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.chuDam,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sinhVien?.email ?? "",
                    style: const TextStyle(color: ThemeApp.chuPhu),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "Điểm TB /10",
                          value: "$gpa10",
                          icon: Icons.star_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: "GPA /4",
                          value: "$gpa4",
                          icon: Icons.school_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "Tổng tín chỉ",
                          value: "$tongTin",
                          icon: Icons.confirmation_number_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: "Học kỳ",
                          value: "${sinhVien?.hocKyHienTai ?? 0}",
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ThemeApp.mauVien),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Xếp loại học lực",
                          style: TextStyle(
                            fontSize: 16,
                            color: ThemeApp.chuPhu,
                          ),
                        ),
                        Text(
                          xepLoai,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: MauHocTap.mauHocLuc(xepLoai),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: ThemeApp.mauVien),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Biểu đồ điểm môn học",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.chuDam,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _nutChon(
                                "Hình tròn",
                                dangTron,
                                () => setState(() => dangTron = true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _nutChon(
                                "Cột",
                                !dangTron,
                                () => setState(() => dangTron = false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BieuDoDiem(ds: dsDiem, dangTron: dangTron),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        SessionService.dangXuat();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/login",
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Đăng xuất"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => SystemNavigator.pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text("Thoát app"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavApp(currentIndex: 3),
        );
      },
    );
  }

  Widget _nutChon(String text, bool chon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: chon ? ThemeApp.mauChinh : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeApp.mauChinh),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: chon ? Colors.white : ThemeApp.mauChinh,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
