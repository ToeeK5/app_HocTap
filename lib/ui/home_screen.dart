import 'package:flutter/material.dart';
import '../services/diem_service.dart';
import '../services/lich_hoc_service.dart';
import '../services/session_service.dart';
import '../services/sinh_vien_service.dart';
import '../utils/theme_app.dart';
import '../utils/tinh_toan_hoc_tap.dart';
import '../widgets/bottom_nav_app.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<LichHocHienThi>> _lichFuture;
  late Future<List<dynamic>> _keHoachFuture;

  @override
  void initState() {
    super.initState();
    final maSV = SessionService.layMaSV();
    _lichFuture = LichHocService().layLichTheoSinhVien(maSV);
    _keHoachFuture = LichHocService()
        .layKeHoachTheoSinhVien(maSV)
        .then((v) => v);
  }

  @override
  Widget build(BuildContext context) {
    final maSV = SessionService.layMaSV();
    final sinhVien = SinhVienService().laySinhVienTheoMa(maSV);
    final dsDiem = DiemService().layDiemTheoSinhVien(maSV);
    final gpa10 = TinhToanHocTap.tinhGPAHe10(dsDiem);
    final tongTin = TinhToanHocTap.tinhTongTin(dsDiem);
    final xepLoai = TinhToanHocTap.xepLoaiHocLuc(gpa10);

    return FutureBuilder<List<LichHocHienThi>>(
      future: _lichFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: ThemeApp.mauNen,
            appBar: AppBar(
              backgroundColor: ThemeApp.mauNen,
              foregroundColor: ThemeApp.chuDam,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final dsLich = snapshot.data!;
        final lichHomNay = dsLich
            .where(
              (item) =>
                  item.lichHoc.thu ==
                  LichHocService().tenThu(DateTime.now().weekday),
            )
            .toList();
        return Scaffold(
          backgroundColor: ThemeApp.mauNen,
          appBar: AppBar(
            backgroundColor: ThemeApp.mauNen,
            foregroundColor: ThemeApp.chuDam,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
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
                          title: 'Lịch học',
                          value: '${dsLich.length}',
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
                  FutureBuilder<List<dynamic>>(
                    future: _keHoachFuture,
                    builder: (context, snapKe) {
                      if (!snapKe.hasData) {
                        return const Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final dsKeHoach = snapKe.data ?? <dynamic>[];
                      if (dsKeHoach.isEmpty)
                        return const _EmptyBox(text: 'Chưa có kế hoạch ôn tập');
                      return Column(
                        children: dsKeHoach
                            .map(
                              (keHoach) => _KeHoachCard(
                                tieuDe: keHoach.tieuDe,
                                noiDung: keHoach.noiDung,
                                ngayOnTap: keHoach.ngayOnTap,
                                trangThai: keHoach.trangThai,
                              ),
                            )
                            .toList(),
                      );
                    },
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
            ),
          ),
          bottomNavigationBar: const BottomNavApp(currentIndex: 0),
        );
      },
    );
  }
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
