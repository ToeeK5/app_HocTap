import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'score_utils.dart';

/// Widget nhập điểm (cho GK hoặc CK)
class ScoreInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const ScoreInputField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

/// Widget hiển thị hàng sinh viên trong bảng
class StudentTableRow {
  final int index;
  final int stt;
  final String mssv;
  final String ten;
  final double gk;
  final double ck;
  final TextEditingController gkController;
  final TextEditingController ckController;
  final Function(int, String, String) onUpdateScore;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  StudentTableRow({
    required this.index,
    required this.stt,
    required this.mssv,
    required this.ten,
    required this.gk,
    required this.ck,
    required this.gkController,
    required this.ckController,
    required this.onUpdateScore,
    required this.onEdit,
    required this.onDelete,
  });

  DataRow toDataRow() {
    double gkValue = double.tryParse(gkController.text) ?? gk;
    double ckValue = double.tryParse(ckController.text) ?? ck;

    double dtb = ScoreUtils.calculateDTB(gkValue, ckValue);
    String status = ScoreUtils.getStatus(dtb);

    return DataRow(
      cells: [
        // STT
        DataCell(
          Text(
            '$stt',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        // MSSV
        DataCell(
          Text(
            mssv,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        // Tên
        DataCell(Text(ten, style: const TextStyle(fontSize: 12))),
        // Giữa kỳ
        DataCell(
          ScoreInputField(
            controller: gkController,
            onChanged: (value) => onUpdateScore(index, 'gk', value),
          ),
        ),
        // Cuối kỳ
        DataCell(
          ScoreInputField(
            controller: ckController,
            onChanged: (value) => onUpdateScore(index, 'ck', value),
          ),
        ),
        // ĐTB
        DataCell(
          Text(
            dtb > 0 ? dtb.toStringAsFixed(1) : '-',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: dtb > 0 ? AppColors.darkBlue : Colors.grey,
            ),
          ),
        ),
        // Trạng thái
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'Đạt'
                  ? AppColors.greenBg
                  : status == 'Trượt'
                      ? AppColors.redBg
                      : Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ScoreUtils.getStatusColor(status),
              ),
            ),
          ),
        ),
        // Hành động
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: AppColors.errorRed,
                ),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
