import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'score_utils.dart';
import '../../../models/mon_hoc.dart';

class FilterAndStatsWidget extends StatelessWidget {
  final String selectedMonHoc;
  final List<MonHoc> danhSachMonHoc;
  final List<Map<String, dynamic>> studentData;
  final Function(String) onMonHocChanged;

  const FilterAndStatsWidget({
    super.key,
    required this.selectedMonHoc,
    required this.danhSachMonHoc,
    required this.studentData,
    required this.onMonHocChanged,
  });

  @override
  Widget build(BuildContext context) {
    double classAverage = ScoreUtils.calculateClassAverage(studentData);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Card (chỉ chọn môn học)
        Expanded(flex: 2, child: _buildFiltersCard()),
        const SizedBox(width: 24),
        // Stats Cards (side-by-side)
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng số SV',
                  '${studentData.length}',
                  Icons.groups,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'ĐTB Lớp',
                  classAverage.toStringAsFixed(1),
                  Icons.analytics,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn Môn Học',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Môn Học Dropdown
          _buildDropdownField(
            label: 'Môn học',
            value: selectedMonHoc.isNotEmpty ? selectedMonHoc : null,
            items: danhSachMonHoc
                .map(
                  (mon) => DropdownMenuItem<String>(
                    value: mon.maMon,
                    child: Text('${mon.maMon} - ${mon.tenMon}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onMonHocChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.accentBlue, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
