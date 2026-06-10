import 'package:flutter/material.dart';

class ScoreUtils {
  /// Tính điểm trung bình: GK * 0.4 + CK * 0.6
  static double calculateDTB(double gk, double ck) {
    if (gk == 0 && ck == 0) return 0;
    return double.parse((gk * 0.4 + ck * 0.6).toStringAsFixed(1));
  }

  /// Lấy trạng thái: Đạt, Trượt, hoặc Chưa nhập
  static String getStatus(double dtb) {
    if (dtb == 0) return 'Chưa nhập';
    return dtb >= 4.0 ? 'Đạt' : 'Trượt';
  }

  /// Lấy màu theo trạng thái
  static Color getStatusColor(String status) {
    const Color successGreen = Color(0xFF117A65);
    const Color errorRed = Color(0xFFC0392B);
    
    switch (status) {
      case 'Đạt':
        return successGreen;
      case 'Trượt':
        return errorRed;
      default:
        return Colors.orange;
    }
  }

  /// Tính điểm trung bình của cả lớp
  static double calculateClassAverage(List<Map<String, dynamic>> students) {
    double totalDTB = 0;
    int count = 0;
    
    for (var student in students) {
      double dtb = calculateDTB(
        student['gk'] as double,
        student['ck'] as double,
      );
      if (dtb > 0) {
        totalDTB += dtb;
        count++;
      }
    }
    
    return count > 0 ? totalDTB / count : 0;
  }
}
