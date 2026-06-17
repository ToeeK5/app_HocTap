import 'package:flutter/material.dart';

import '../models/sinh_vien.dart';
import '../services/diem_service.dart';
import '../services/lich_hoc_service.dart';
import '../services/session_service.dart';
import '../services/sinh_vien_service.dart';
import '../utils/theme_app.dart';
import '../utils/tinh_toan_hoc_tap.dart';
import '../widgets/bottom_nav_app.dart';
import '../widgets/stat_card.dart';
import 'dang_ky_hoc_phan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> futureHome;

  @override
  void initState() {
    super.initState();
    futureHome = _loadHome();
  }

  Future<_HomeData> _loadHome() async {
    final maSV = SessionService.layMaSV();

    final sinhVien = await SinhVienService().laySinhVienTheoMa(maSV);
    final dsDiem = await DiemService().layDiemTheoSinhVien(maSV);
    final dsLich = await LichHocService().layLichThucTeTheoSinhVien(maSV);
    final dsKeHoach = LichHocService().layKeHoachTheoSinhVien(maSV);

    // Build set of registered course codes (distinct)
    final registeredMaMon = <String>{};
    for (final item in dsLich) {
      registeredMaMon.add(item.lichHoc.maMon);
    }

    // Filter dsDiem to only include grades for registered courses
    final dsDiemDangKy = dsDiem
        .where((d) => registeredMaMon.contains(d.diem.maMon))
        .toList();

    // Compute total credits from the filtered grade list (distinct monHoc)
    final distinctMonForCredits = <String>{};
    int tongTinDangKy = 0;
    for (final d in dsDiemDangKy) {
      final maMon = d.monHoc.maMon;
      if (!distinctMonForCredits.contains(maMon)) {
        distinctMonForCredits.add(maMon);
        tongTinDangKy += d.monHoc.soTinChi;
      }
    }

    return _HomeData(
      sinhVien: sinhVien,
      dsDiem: dsDiem,
      dsDiemDangKy: dsDiemDangKy,
      dsLich: dsLich,
      tongTinDangKy: tongTinDangKy,
      dsKeHoach: dsKeHoach,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maSV = SessionService.layMaSV();

    return Scaffold(
      backgroundColor: ThemeApp.mauNen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: ThemeApp.mauNen,
        elevation: 0,
        title: const Text(
          "TRANG CHỦ",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: ThemeApp.chuDam,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<_HomeData>(
          future: futureHome,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Không tải được dữ liệu"));
            }

            final sinhVien = snapshot.data!.sinhVien;
            final dsLich = snapshot.data!.dsLich;
            final dsKeHoach = snapshot.data!.dsKeHoach;

            // Use only grades for registered courses when computing GPA and credits
            final dsDiemDangKy = snapshot.data!.dsDiemDangKy;
            final gpa10 = TinhToanHocTap.tinhGPAHe10(dsDiemDangKy);
            final tongTin = snapshot.data!.tongTinDangKy;
            final xepLoai = TinhToanHocTap.xepLoaiHocLuc(gpa10);

            final thuHomNay = LichHocService().tenThu(DateTime.now().weekday);
            final lichHomNay = dsLich
                .where((item) => item.lichHoc.thu == thuHomNay)
                .toList();

            // detect classes that are happening now (current time between start and end)
            int timeToMinutes(String t) {
              final parts = t.split(':');
              final h = int.tryParse(parts[0]) ?? 0;
              final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
              return h * 60 + m;
            }

            final now = DateTime.now();
            final nowMinutes = now.hour * 60 + now.minute;
            final lichDangDienRa = lichHomNay.where((item) {
              final start = item.lichHoc.gioBatDau;
              final end = item.lichHoc.gioKetThuc;
              try {
                final s = timeToMinutes(start);
                final e = timeToMinutes(end);
                return s <= nowMinutes && nowMinutes <= e;
              } catch (_) {
                return false;
              }
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    tenSinhVien: sinhVien?.hoTen ?? 'Sinh viên',
                    maSV: maSV,
                    lop: sinhVien?.lop ?? '',
                    hocKy: sinhVien?.hocKyHienTai ?? 0,
                  ),

                  const SizedBox(height: 8),
                  // Hiển thị nút đăng ký khi học kỳ là 3 hoặc 4
                  if ((sinhVien?.hocKyHienTai ?? 0) == 3 ||
                      (sinhVien?.hocKyHienTai ?? 0) == 4)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeApp.mauChinh,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DangKyHocPhanScreen(
                                hocKy: sinhVien?.hocKyHienTai ?? 3,
                              ),
                            ),
                          );
                        },
                        child: const Text('Đăng ký theo kỳ'),
                      ),
                    ),

                  // Banner hiển thị các lớp đang diễn ra ngay bây giờ (nếu có)
                  if (lichDangDienRa.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lớp đang diễn ra ngay bây giờ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          ...lichDangDienRa.map(
                            (item) => Text(
                              '${item.monHoc.tenMon} | ${item.lichHoc.gioBatDau} - ${item.lichHoc.gioKetThuc} | Phòng ${item.lichHoc.phongHoc}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Điểm TB /10',
                          value: '$gpa10',
                          icon: Icons.star_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Số tín chỉ',
                          value: '$tongTin',
                          icon: Icons.confirmation_number_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Lịch học (số môn)',
                          value:
                              '${dsLich.map((e) => e.lichHoc.maMon).toSet().length}',
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Học lực',
                          value: xepLoai,
                          icon: Icons.school_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _SectionTitle(
                    title: 'Lịch học hôm nay',
                    actionText: 'Xem lịch',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/lichhoc'),
                  ),

                  const SizedBox(height: 10),

                  if (lichHomNay.isEmpty)
                    const _EmptyBox(text: 'Hôm nay không có lịch học')
                  else
                    ...lichHomNay.map((item) => _LichCard(item: item)),

                  const SizedBox(height: 18),

                  const _SectionTitle(title: 'Kế hoạch ôn tập'),

                  const SizedBox(height: 10),

                  if (dsKeHoach.isEmpty)
                    const _EmptyBox(text: 'Chưa có kế hoạch ôn tập')
                  else
                    ...dsKeHoach.map(
                      (keHoach) => _KeHoachCard(
                        tieuDe: keHoach.tieuDe,
                        noiDung: keHoach.noiDung,
                        ngayOnTap: keHoach.ngayOnTap,
                        trangThai: keHoach.trangThai,
                      ),
                    ),

                  const SizedBox(height: 18),

                  const _SectionTitle(title: 'Môn học đang theo dõi'),

                  const SizedBox(height: 10),

                  if (dsLich.isEmpty)
                    const _EmptyBox(text: 'Chưa có môn học trong lịch')
                  else
                    ...dsLich.take(3).map((item) => _MonHocCard(item: item)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavApp(currentIndex: 0),
    );
  }
}

class _HomeData {
  final SinhVien? sinhVien;
  final List<DiemMonHienThi> dsDiem;
  final List<DiemMonHienThi> dsDiemDangKy;
  final List<LichHocHienThi> dsLich;
  final int tongTinDangKy;
  final List<dynamic> dsKeHoach;

  _HomeData({
    required this.sinhVien,
    required this.dsDiem,
    required this.dsDiemDangKy,
    required this.dsLich,
    required this.tongTinDangKy,
    required this.dsKeHoach,
  });
}

class _Header extends StatelessWidget {
  final String tenSinhVien;
  final String maSV;
  final String lop;
  final int hocKy;

  const _Header({
    required this.tenSinhVien,
    required this.maSV,
    required this.lop,
    required this.hocKy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeApp.mauChinh,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              size: 36,
              color: ThemeApp.mauIcon,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, $tenSinhVien',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$maSV - Lớp $lop - Học kỳ $hocKy',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const _SectionTitle({required this.title, this.actionText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeApp.chuDam,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionText!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}

class _LichCard extends StatelessWidget {
  final LichHocHienThi item;

  const _LichCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final lich = item.lichHoc;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThemeApp.mauPhu,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.schedule_rounded, color: ThemeApp.mauIcon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.monHoc.tenMon,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.chuDam,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lich.thu}, ${lich.gioBatDau} - ${lich.gioKetThuc} | Phòng ${lich.phongHoc}',
                  style: const TextStyle(color: ThemeApp.chuPhu),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeHoachCard extends StatelessWidget {
  final String tieuDe;
  final String noiDung;
  final String ngayOnTap;
  final String trangThai;

  const _KeHoachCard({
    required this.tieuDe,
    required this.noiDung,
    required this.ngayOnTap,
    required this.trangThai,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: ThemeApp.mauIcon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tieuDe,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.chuDam,
                  ),
                ),
              ),
              Text(
                trangThai,
                style: const TextStyle(
                  color: ThemeApp.mauChinh,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(noiDung, style: const TextStyle(color: ThemeApp.chuPhu)),
          const SizedBox(height: 6),
          Text(
            'Ngày ôn tập: $ngayOnTap',
            style: const TextStyle(color: ThemeApp.chuPhu, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MonHocCard extends StatelessWidget {
  final LichHocHienThi item;

  const _MonHocCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final mon = item.monHoc;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: ThemeApp.mauIcon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mon.tenMon,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeApp.chuDam,
              ),
            ),
          ),
          Text(
            '${mon.soTinChi} tín chỉ',
            style: const TextStyle(color: ThemeApp.chuPhu),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;

  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: ThemeApp.chuPhu),
      ),
    );
  }
}
