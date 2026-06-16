import 'package:flutter/material.dart';
import 'app_colors.dart';

class PageHeaderWidget extends StatelessWidget {
  final VoidCallback onAddStudent;
  final VoidCallback onSaveAll;
  final VoidCallback onQuickAddLop;
  final VoidCallback onQuickAddHocKy;

  const PageHeaderWidget({
    super.key,
    required this.onAddStudent,
    required this.onSaveAll,
    required this.onQuickAddLop,
    required this.onQuickAddHocKy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập điểm sinh viên',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Học kỳ 1 - Năm học 2023-2024',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            // Nút thêm Lớp học nhanh
            OutlinedButton.icon(
              onPressed: onQuickAddLop,
              icon: const Icon(Icons.domain_add),
              label: const Text('Thêm lớp'),
            ),
            const SizedBox(width: 8),

            // Nút thêm Học kỳ nhanh
            OutlinedButton.icon(
              onPressed: onQuickAddHocKy,
              icon: const Icon(Icons.more_time),
              label: const Text('Thêm học kỳ'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAddStudent,
              icon: const Icon(Icons.person_add),
              label: const Text('Thêm sinh viên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onSaveAll,
              icon: const Icon(Icons.save),
              label: const Text('Lưu bảng điểm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
