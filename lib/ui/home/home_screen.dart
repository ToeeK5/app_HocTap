import 'package:flutter/material.dart';
import '../../widgets/overview_card.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        title: const Text(
          'QUẢN LÝ HỌC TẬP SINH VIÊN',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 14), child: Icon(Icons.mail)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _phanDauTrang(),

              const SizedBox(height: 22),

              _tienDoHocTap(),

              const SizedBox(height: 24),

              const Text(
                'Tổng quan học tập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Row(
                children: [
                  OverviewCard(
                    icon: Icons.grade,
                    title: 'GPA',
                    value: '0',
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  OverviewCard(
                    icon: Icons.menu_book,
                    title: 'Số môn',
                    value: '0',
                    color: Colors.blue,
                  ),
                  SizedBox(width: 10),
                  OverviewCard(
                    icon: Icons.school,
                    title: 'Tín chỉ',
                    value: '0',
                    color: Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 26),

              const Text(
                'Môn học sắp tới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _monHocSapToi(),

              const SizedBox(height: 26),

              const Text(
                'Lịch học hôm nay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _lichGanNhat(
                tenMon: 'Lập trình Flutter',
                thoiGian: '07:00 - 09:30',
                phong: 'Phòng A203',
              ),

              _lichGanNhat(
                tenMon: 'Cơ sở dữ liệu',
                thoiGian: '09:45 - 11:15',
                phong: 'Phòng B105',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phanDauTrang() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF2563EB), size: 34),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, Hiệp 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Thứ 5, ngày 21/05/2026',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),

                SizedBox(height: 6),

                Text(
                  'Theo dõi GPA, môn học và tín chỉ của bạn',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tienDoHocTap() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ học tập học kỳ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '0%',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0.0,
              minHeight: 10,
              backgroundColor: Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monHocSapToi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available,
              color: Colors.blue,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lập trình Android',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 5),

                Text(
                  '13:00 - 15:30 • Phòng C301',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lichGanNhat({
    required String tenMon,
    required String thoiGian,
    required String phong,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.access_time, color: Colors.blue),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenMon,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$thoiGian • $phong',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
