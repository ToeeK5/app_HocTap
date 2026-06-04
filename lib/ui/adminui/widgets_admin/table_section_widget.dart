import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'score_input_field.dart';

class TableSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> studentData;
  final Map<int, Map<String, TextEditingController>> controllers;
  final Function(int, String, String) onUpdateScore;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final int currentPage;
  final Function(int) onPageChanged;

  const TableSectionWidget({
    super.key,
    required this.studentData,
    required this.controllers,
    required this.onUpdateScore,
    required this.onEdit,
    required this.onDelete,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildTableHeader(),
          const Divider(height: 1, color: AppColors.borderColor),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _buildTable(),
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.borderColor),
          _buildTableFooter(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Danh sách nhập điểm',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.hoverBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Tổng: ${studentData.length} SV',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF165E81),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Lưu tất cả',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return DataTable(
      columnSpacing: 24,
      dataRowHeight: 60,
      headingRowHeight: 56,
      headingRowColor: MaterialStateColor.resolveWith(
        (states) => AppColors.backgroundColor,
      ),
      columns: const [
        DataColumn(
          label: Text(
            'STT',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          numeric: false,
        ),
        DataColumn(
          label: Text(
            'MSSV',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Họ và Tên',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Giữa kỳ (0.4)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Cuối kỳ (0.6)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'ĐTB',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Trạng thái',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Hành động',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
      rows: _buildDataRows(),
    );
  }

  List<DataRow> _buildDataRows() {
    return studentData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> data = entry.value;

        final row = StudentTableRow(
        index: index,
        stt: data['stt'] as int,
        mssv: data['mssv'] as String,
        ten: data['ten'] as String,
        gk: data['gk'] as double,
        ck: data['ck'] as double,
        gkController: controllers[index]?['gk'] ?? TextEditingController(),
        ckController: controllers[index]?['ck'] ?? TextEditingController(),
        onUpdateScore: onUpdateScore,
        onEdit: () => onEdit(index),
        onDelete: () => onDelete(index),
      );

        return row.toDataRow();
      }).toList();
    }

  Widget _buildTableFooter() {
    int totalStudents = studentData.length;
    int itemsPerPage = 4;
    int totalPages = (totalStudents / itemsPerPage).ceil();
    int startIndex = (currentPage - 1) * itemsPerPage + 1;
    int endIndex = (currentPage * itemsPerPage).clamp(0, totalStudents);

    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị $startIndex-$endIndex trên $totalStudents sinh viên',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Row(
            children: [
              _buildPaginationButton(Icons.chevron_left, () {
                if (currentPage > 1) onPageChanged(currentPage - 1);
              }),
              ..._buildPageNumbers(totalPages),
              _buildPaginationButton(Icons.chevron_right, () {
                if (currentPage < totalPages) onPageChanged(currentPage + 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pages = [];
    for (int i = 1; i <= totalPages && i <= 3; i++) {
      pages.add(_buildPaginationPageButton('$i', currentPage == i));
      if (i < totalPages && i == 2) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        );
        break;
      }
    }
    return pages;
  }

  Widget _buildPaginationButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPaginationPageButton(String page, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.shadowBlue : Colors.transparent,
        border: Border.all(
          color: isActive ? AppColors.accentBlue : AppColors.borderColor,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          page,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.darkBlue : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
