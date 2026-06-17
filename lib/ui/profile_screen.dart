import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sinh_vien.dart';
import '../services/session_service.dart';
import '../services/sinh_vien_service.dart';
import '../services/diem_service.dart';
import '../services/dang_ky_service.dart';
import '../utils/tinh_toan_hoc_tap.dart';
import '../utils/theme_app.dart';
import '../widgets/bottom_nav_app.dart';
import '../widgets/stat_card.dart';
import '../widgets/bieu_do_diem.dart';
import '../utils/mau_hoc_tap.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dangTron = true;
  late Future<_ProfileData> futureData;

  @override
  void initState() {
    super.initState();
    futureData = _loadData();
  }

  Future<_ProfileData> _loadData() async {
    final maSV = SessionService.layMaSV();
    final sinhVien = await SinhVienService().laySinhVienTheoMa(maSV);
    final dsDiemAll = await DiemService().layDiemTheoSinhVien(maSV);

    // Lọc chỉ lấy các môn đã đăng ký ở học kỳ hiện tại để tổng tín chỉ / GPA khớp với trang Home
    final hocKyHienTai = sinhVien?.hocKyHienTai ?? 1;
    final dsMaDangKy = await DangKyService().layMonDaDangKy(maSV, hocKyHienTai);

    final dsDiem = dsDiemAll
        .where((d) => dsMaDangKy.contains(d.monHoc.maMon))
        .toList();

    return _ProfileData(sinhVien: sinhVien, dsDiem: dsDiem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.mauNen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "TRANG CÁ NHÂN",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: ThemeApp.chuDam,
          ),
        ),
        centerTitle: true,
        backgroundColor: ThemeApp.mauNen,
        foregroundColor: ThemeApp.chuDam,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<_ProfileData>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Không tải được dữ liệu"));
            }

            final sinhVien = snapshot.data!.sinhVien;
            final dsDiem = snapshot.data!.dsDiem;
            final gpa10 = TinhToanHocTap.tinhGPAHe10(dsDiem);
            final gpa4 = TinhToanHocTap.tinhGPAHe4(gpa10);
            final tongTin = TinhToanHocTap.tinhTongTin(dsDiem);
            final xepLoai = TinhToanHocTap.xepLoaiHocLuc(gpa10);

            return SingleChildScrollView(
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
                        if (dsDiem.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Text(
                                "Chưa có dữ liệu điểm",
                                style: TextStyle(color: ThemeApp.chuPhu),
                              ),
                            ),
                          )
                        else
                          BieuDoDiem(ds: dsDiem, dangTron: dangTron),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _hienDanhGia(context, dsDiem, gpa10, xepLoai),
                          icon: const Icon(
                            Icons.psychology_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Xem đánh giá",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeApp.mauChinh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _hienTienDoRaTruong(context, tongTin),
                          icon: const Icon(Icons.flag_rounded),
                          label: const Text("Tiến độ"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
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
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavApp(currentIndex: 3),
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

  void _hienDanhGia(
    BuildContext context,
    List<DiemMonHienThi> dsDiem,
    double gpa10,
    String xepLoai,
  ) {
    final monDat = dsDiem.where((e) => e.diemTongKet >= 5).length;
    final monRot = dsDiem.where((e) => e.diemTongKet < 5).length;
    final monCanCaiThien = dsDiem.where((e) => e.diemTongKet < 6.5).length;

    String nhanXet = "";

    if (gpa10 >= 8) {
      nhanXet = "Kết quả học tập tốt. Tiếp tục duy trì thành tích hiện tại.";
    } else if (gpa10 >= 6.5) {
      nhanXet = "Kết quả học tập khá. Nên cải thiện thêm các môn điểm thấp.";
    } else if (gpa10 >= 5) {
      nhanXet = "Đã đạt yêu cầu nhưng cần cố gắng hơn để nâng GPA.";
    } else {
      nhanXet =
          "Có nhiều môn chưa đạt. Cần tập trung cải thiện kết quả học tập.";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đánh giá học tập"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("GPA hệ 10: ${gpa10.toStringAsFixed(2)}"),
            Text("Xếp loại: $xepLoai"),
            Text("Môn đạt: $monDat"),
            Text("Môn chưa đạt: $monRot"),
            Text("Môn cần cải thiện: $monCanCaiThien"),
            const SizedBox(height: 12),
            Text(nhanXet),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  void _hienTienDoRaTruong(BuildContext context, int tongTin) {
    const tongTinTotNghiep = 120;

    final phanTram = ((tongTin / tongTinTotNghiep) * 100)
        .clamp(0, 100)
        .toStringAsFixed(1);

    final conThieu = tongTinTotNghiep - tongTin;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tiến độ ra trường"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tín chỉ đã tích lũy: $tongTin/$tongTinTotNghiep"),
            Text("Tiến độ hoàn thành: $phanTram%"),
            Text("Tín chỉ còn thiếu: ${conThieu < 0 ? 0 : conThieu}"),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: tongTin / tongTinTotNghiep),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }
}

class _ProfileData {
  final SinhVien? sinhVien;
  final List<DiemMonHienThi> dsDiem;

  _ProfileData({required this.sinhVien, required this.dsDiem});
}
