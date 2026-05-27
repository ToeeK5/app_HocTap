import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String namHocDangChon = '2025-2026';
  String hocKyDangChon = 'Học kỳ 1';
  String tuanDangChon = '1';

  final List<String> danhSachNamHoc = [
    '2024-2025',
    '2025-2026',
    '2026-2027',
  ];

  final List<String> danhSachHocKy = [
    'Học kỳ 1',
    'Học kỳ 2',
    'Học kỳ hè',
  ];

  final List<String> danhSachTuan = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _tieuDe(),
              const SizedBox(height: 12),
              _thongTinSinhVien(),
              const SizedBox(height: 8),
              _boLoc(),
              const SizedBox(height: 8),
              _bangThoiKhoaBieu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tieuDe() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.blue),
          SizedBox(width: 10),
          Text(
            'THỜI KHÓA BIỂU',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _thongTinSinhVien() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF008CC8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SINH VIÊN CHỌN TUẦN ĐỂ XEM LỊCH',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.person, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Lê Thành Hiệp',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),

          SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.badge, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'MSSV: 23211tt2605',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boLoc() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _boLocItem(
                nhan: 'Tuần:',
                child: _hopChon(
                  giaTri: tuanDangChon,
                  danhSach: danhSachTuan,
                  khiChon: (giaTriMoi) {
                    setState(() {
                      tuanDangChon = giaTriMoi!;
                    });
                  },
                ),
              ),

              _boLocItem(
                nhan: 'Năm học:',
                child: _hopChon(
                  giaTri: namHocDangChon,
                  danhSach: danhSachNamHoc,
                  khiChon: (giaTriMoi) {
                    setState(() {
                      namHocDangChon = giaTriMoi!;
                    });
                  },
                ),
              ),

              _boLocItem(
                nhan: 'Học kỳ:',
                child: _hopChon(
                  giaTri: hocKyDangChon,
                  danhSach: danhSachHocKy,
                  khiChon: (giaTriMoi) {
                    setState(() {
                      hocKyDangChon = giaTriMoi!;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(Icons.date_range, size: 18, color: Colors.red),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Từ ngày 01/01/2026 đến ngày 07/01/2026',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boLocItem({
    required String nhan,
    required Widget child,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          nhan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        child,
      ],
    );
  }

  Widget _hopChon({
    required String giaTri,
    required List<String> danhSach,
    required void Function(String?) khiChon,
  }) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: giaTri,
        underline: const SizedBox(),
        iconSize: 18,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
        ),
        items: danhSach.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: khiChon,
      ),
    );
  }

  Widget _bangThoiKhoaBieu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _oTieuDe('PHÒNG', 70),
                      _oTieuDe('THỨ 2', 180),
                      _oTieuDe('THỨ 3', 180),
                      _oTieuDe('THỨ 4', 180),
                      _oTieuDe('THỨ 5', 180),
                      _oTieuDe('THỨ 6', 180),
                      _oTieuDe('THỨ 7', 180),
                      _oTieuDe('CHỦ NHẬT', 180),
                    ],
                  ),

                  _dongLich(
                    phong: 'A001',
                    lichThu2: _monHoc(
                      mauNen: const Color(0xFF9DBBEA),
                      maMon: 'asd126',
                      tenMon: 'Tiếng Anh',
                      tiet: 'Tiết 1-5',
                      thoiGian: '07h00 -> 11h10',
                      giangVien: 'Thầy 3',
                    ),
                    lichThu4: _monHoc(
                      mauNen: const Color(0xFF9DBBEA),
                      maMon: 'asd125',
                      tenMon: 'Thể Chất',
                      tiet: 'Tiết 2-6',
                      thoiGian: '07h45 -> 11h55',
                      giangVien: 'Thầy 2',
                    ),
                  ),

                  _dongLich(
                    phong: 'A002',
                    lichThu4: _monHoc(
                      mauNen: const Color(0xFFC7A2F3),
                      maMon: 'asd124',
                      tenMon: 'Triển Khai',
                      tiet: 'Tiết 7-11',
                      thoiGian: '12h45 -> 16h55',
                      giangVien: 'Thầy 1',
                    ),
                  ),

                  _dongLich(
                    phong: 'A003',
                    lichThu5: _monHoc(
                      mauNen: const Color(0xFFF2A3B7),
                      maMon: 'asd123',
                      tenMon: 'Lập trình di động 3',
                      tiet: 'Tiết 7-11',
                      thoiGian: '12h45 -> 16h55',
                      giangVien: 'Trương Bá Thái',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _oTieuDe(String noiDung, double rong) {
    return Container(
      width: rong,
      height: 30,
      alignment: Alignment.center,
      color: Colors.blue,
      child: Text(
        noiDung,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _dongLich({
    required String phong,
    Widget? lichThu2,
    Widget? lichThu3,
    Widget? lichThu4,
    Widget? lichThu5,
    Widget? lichThu6,
    Widget? lichThu7,
    Widget? lichChuNhat,
  }) {
    return Row(
      children: [
        _oPhong(phong),
        _oNgay(lichThu2),
        _oNgay(lichThu3),
        _oNgay(lichThu4),
        _oNgay(lichThu5),
        _oNgay(lichThu6),
        _oNgay(lichThu7),
        _oNgay(lichChuNhat),
      ],
    );
  }

  Widget _oPhong(String phong) {
    return Container(
      width: 70,
      height: 120,
      alignment: Alignment.center,
      color: const Color(0xFFD9D9D9),
      child: Text(
        phong,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _oNgay(Widget? noiDung) {
    return Container(
      width: 180,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
      ),
      child: noiDung,
    );
  }

  Widget _monHoc({
    required Color mauNen,
    required String maMon,
    required String tenMon,
    required String tiet,
    required String thoiGian,
    required String giangVien,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      color: mauNen,
      child: Text(
        '$maMon-$tenMon\n'
        '$thoiGian\n'
        '$tiet\n'
        'GV: $giangVien\n'
        'Địa chỉ: TP Hồ Chí Minh\n'
        'Tín chỉ: 3',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}