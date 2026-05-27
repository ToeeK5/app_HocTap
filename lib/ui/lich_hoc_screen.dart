import 'package:flutter/material.dart';

import '../services/lich_hoc_service.dart';
import '../services/session_service.dart';
import '../services/sinh_vien_service.dart';
import '../utils/theme_app.dart';
import '../widgets/bottom_nav_app.dart';

class LichHocScreen extends StatefulWidget {
  const LichHocScreen({super.key});

  @override
  State<LichHocScreen> createState() => _LichHocScreenState();
}

class _LichHocScreenState extends State<LichHocScreen> {
  int? hocKyDangChon;
  bool chiHomNay = false;

  @override
  Widget build(BuildContext context) {
    final maSV = SessionService.layMaSV();
    final sinhVien = SinhVienService().laySinhVienTheoMa(maSV);
    final service = LichHocService();
    final dsTatCa = service.layLichTheoSinhVien(maSV);
    final dsHocKy = _danhSachHocKy(dsTatCa, sinhVien?.hocKyHienTai);
    final hocKy = hocKyDangChon ??
        sinhVien?.hocKyHienTai ??
        (dsHocKy.isEmpty ? null : dsHocKy.first);

    var dsHienThi = dsTatCa;
    if (hocKy != null) {
      dsHienThi = dsHienThi.where((item) => item.monHoc.hocKy == hocKy).toList();
    }
    if (chiHomNay) {
      final thuHomNay = service.tenThu(DateTime.now().weekday);
      dsHienThi = dsHienThi
          .where((item) => item.lichHoc.thu == thuHomNay)
          .toList();
    }
    dsHienThi = service.sapXepLich(dsHienThi);

    return Scaffold(
      backgroundColor: ThemeApp.mauNen,
      appBar: AppBar(
        title: const Text('Lịch học'),
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
              _ThongTinSinhVien(
                ten: sinhVien?.hoTen ?? 'Sinh viên',
                maSV: maSV,
                lop: sinhVien?.lop ?? '',
                hocKy: sinhVien?.hocKyHienTai ?? 0,
              ),
              const SizedBox(height: 16),
              _BoLoc(
                hocKyDangChon: hocKy,
                danhSachHocKy: dsHocKy,
                chiHomNay: chiHomNay,
                onChonHocKy: (value) => setState(() => hocKyDangChon = value),
                onDoiHomNay: (value) => setState(() => chiHomNay = value),
              ),
              const SizedBox(height: 18),
              Text(
                chiHomNay ? 'Lịch học hôm nay' : 'Lịch học trong tuần',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.chuDam,
                ),
              ),
              const SizedBox(height: 12),
              if (dsHienThi.isEmpty)
                const _EmptyBox(text: 'Không có lịch học phù hợp')
              else
                ...dsHienThi.map((item) => _LichHocCard(item: item)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavApp(currentIndex: 1),
    );
  }

  List<int> _danhSachHocKy(List<LichHocHienThi> dsLich, int? hocKyHienTai) {
    final danhSach = dsLich.map((item) => item.monHoc.hocKy).toSet().toList()
      ..sort();
    if (hocKyHienTai != null && !danhSach.contains(hocKyHienTai)) {
      danhSach.add(hocKyHienTai);
      danhSach.sort();
    }
    return danhSach;
  }
}

class _ThongTinSinhVien extends StatelessWidget {
  final String ten;
  final String maSV;
  final String lop;
  final int hocKy;

  const _ThongTinSinhVien({
    required this.ten,
    required this.maSV,
    required this.lop,
    required this.hocKy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ThemeApp.mauPhu,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: ThemeApp.mauIcon,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ten,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.chuDam,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$maSV - Lớp $lop - Học kỳ $hocKy',
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

class _BoLoc extends StatelessWidget {
  final int? hocKyDangChon;
  final List<int> danhSachHocKy;
  final bool chiHomNay;
  final ValueChanged<int?> onChonHocKy;
  final ValueChanged<bool> onDoiHomNay;

  const _BoLoc({
    required this.hocKyDangChon,
    required this.danhSachHocKy,
    required this.chiHomNay,
    required this.onChonHocKy,
    required this.onDoiHomNay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: hocKyDangChon,
              decoration: const InputDecoration(
                labelText: 'Học kỳ',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: danhSachHocKy
                  .map(
                    (hocKy) => DropdownMenuItem<int>(
                      value: hocKy,
                      child: Text('Học kỳ $hocKy'),
                    ),
                  )
                  .toList(),
              onChanged: onChonHocKy,
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Hôm nay'),
            selected: chiHomNay,
            onSelected: onDoiHomNay,
            selectedColor: ThemeApp.mauPhu,
            checkmarkColor: ThemeApp.mauIcon,
          ),
        ],
      ),
    );
  }
}

class _LichHocCard extends StatelessWidget {
  final LichHocHienThi item;

  const _LichHocCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final lich = item.lichHoc;
    final mon = item.monHoc;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeApp.mauVien),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: ThemeApp.mauPhu,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_month_rounded, color: ThemeApp.mauIcon),
                const SizedBox(height: 6),
                Text(
                  lich.thu.replaceFirst('Thứ ', 'T'),
                  style: const TextStyle(
                    color: ThemeApp.chuDam,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mon.tenMon,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.chuDam,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${lich.gioBatDau} - ${lich.gioKetThuc}',
                  style: const TextStyle(
                    color: ThemeApp.mauChinh,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${mon.maMon} - ${mon.soTinChi} tín chỉ - Phòng ${lich.phongHoc}',
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

class _EmptyBox extends StatelessWidget {
  final String text;

  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
