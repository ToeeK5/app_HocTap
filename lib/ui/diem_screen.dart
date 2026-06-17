import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../services/diem_service.dart';
import '../services/dang_ky_service.dart';
import '../utils/tinh_toan_hoc_tap.dart';
import '../utils/theme_app.dart';
import '../widgets/bottom_nav_app.dart';
import '../utils/mau_hoc_tap.dart';
import '../widgets/comment_section.dart';


class DiemScreen extends StatefulWidget {
  const DiemScreen({super.key});

  @override
  State<DiemScreen> createState() => _DiemScreenState();
}

class _DiemScreenState extends State<DiemScreen> {
  final timController = TextEditingController();
  late Future<List<DiemMonHienThi>> futureDiem;
  late Future<List<String>> futureMaDangKy;
  double diemLoc = 0;
  bool sapXepCaoXuongThap = true;
  int? hocKyLoc;
  @override
  void initState() {
    super.initState();
    final maSV = SessionService.layMaSV();
    futureDiem = DiemService().layDiemTheoSinhVien(maSV);
    // load registered course ids for current student (all semesters may be used elsewhere)
    // We'll load current semester registered list when building
    futureMaDangKy = DangKyService().layMonDaDangKyTatCa(maSV);
  }

  @override
  void dispose() {
    timController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.mauNen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 75,
        backgroundColor: ThemeApp.mauNen,
        elevation: 0,
        title: Column(
          children: const [
            Text(
              "ĐIỂM HỌC TẬP",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeApp.chuDam,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<DiemMonHienThi>>(
          future: futureDiem,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Không tải được dữ liệu điểm"));
            }

            final dsGoc = snapshot.data!;
            print(dsGoc.map((e) => e.diem.hocKySinhVien).toList());
            print(dsGoc.map((e) => e.monHoc.hocKy).toList());
            final tuKhoa = timController.text.toLowerCase();

            final dsDiem = dsGoc.where((item) {
              final ten = item.monHoc.tenMon.toLowerCase();
              final ma = item.monHoc.maMon.toLowerCase();
              final dungTimKiem = ten.contains(tuKhoa) || ma.contains(tuKhoa);
              final dungDiemLoc = item.diemTongKet >= diemLoc;
              //
              final dungHocKy =
    hocKyLoc == null ||
    item.monHoc.hocKy == hocKyLoc;
              //
              return dungTimKiem && dungDiemLoc && dungHocKy;
            }).toList();
  
            dsDiem.sort((a, b) {
              if (sapXepCaoXuongThap) {
                return b.diemTongKet.compareTo(a.diemTongKet);
              }

              return a.diemTongKet.compareTo(b.diemTongKet);
            });

            final tongTin = TinhToanHocTap.tinhTongTin(dsGoc);
            final gpa10 = TinhToanHocTap.tinhGPAHe10(dsGoc);
            final dsHocKy =
    dsGoc
        .map((e) => e.monHoc.hocKy)
        .toSet()
        .toList()
      ..sort();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _theTongKet(
                              "Tổng tín chỉ",
                              "$tongTin",
                              Icons.confirmation_number_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _theTongKet(
                              "Điểm TB /10",
                              "$gpa10",
                              Icons.star_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ThemeApp.mauVien),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bộ lọc điểm",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.chuDam,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: ThemeApp.mauVien),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bộ lọc điểm",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeApp.chuDam,
                              ),
                            ),

                            const SizedBox(height: 10),



                        DropdownButtonFormField<int>(
  value: hocKyLoc ?? -1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xffF8FCFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: -1,
                              child: Text("Tất cả học kỳ"),
                            ),
                            ...dsHocKy.map(
                              (hk) => DropdownMenuItem<int>(
                                value: hk,
                                child: Text("Học kỳ $hk"),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              hocKyLoc = value == -1 ? null : value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    sapXepCaoXuongThap = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: Colors.white,

                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text("Tất cả"),
                                ),
                                DropdownMenuItem(
                                  value: 7,
                                  child: Text("Điểm từ 7 trở lên"),
                                ),
                                DropdownMenuItem(
                                  value: 8,
                                  child: Text("Điểm từ 8 trở lên"),
                                ),
                                DropdownMenuItem(
                                  value: 9,
                                  child: Text("Điểm từ 9 trở lên"),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  diemLoc = value ?? 0;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        sapXepCaoXuongThap = true;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_downward_rounded,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Cao → Thấp",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: sapXepCaoXuongThap
                                          ? ThemeApp.mauChinh
                                          : ThemeApp.mauIcon,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        sapXepCaoXuongThap = false;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Thấp → Cao",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !sapXepCaoXuongThap
                                          ? ThemeApp.mauChinh
                                          : ThemeApp.mauIcon,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "Danh sách môn học",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: ThemeApp.chuDam,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (dsDiem.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text(
                              "Không có môn học",
                              style: TextStyle(color: ThemeApp.chuPhu),
                            ),
                          ),
                        ),

                      ...dsDiem.map((item) => _cardDiem(item)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavApp(currentIndex: 2),
    );
  }

  Widget _theTongKet(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeApp.mauVien),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: ThemeApp.mauIcon),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeApp.chuDam,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: ThemeApp.chuPhu),
          ),
        ],
      ),
    );
  }

  Widget _cardDiem(DiemMonHienThi item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ThemeApp.mauVien),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ThemeApp.mauPhu,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: ThemeApp.mauIcon,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.monHoc.tenMon,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: ThemeApp.chuDam,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Mã môn: ${item.monHoc.maMon} - ${item.monHoc.soTinChi} tín chỉ",
                      style: const TextStyle(color: ThemeApp.chuPhu),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: MauHocTap.mauDiem(item.diemTongKet),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  item.diemTongKet.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _oDiem(
                  "Giữa kỳ",
                  item.diem.diemGiuaKy.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _oDiem(
                  "Cuối kỳ",
                  item.diem.diemCuoiKy.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _oDiem("Tổng", item.diemTongKet.toStringAsFixed(1)),
              ),
              
            ],
            
          ),
          const SizedBox(height: 14),

CommentSection(
  maMon: item.monHoc.maMon,
),
        ],
      ),
    );
  }

  Widget _oDiem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8FCFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeApp.mauChinh,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: ThemeApp.chuPhu),
          ),
        ],
      ),
    );
  }
}
