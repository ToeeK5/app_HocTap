import 'class_subject_info.dart';
import 'student_score.dart';

class ScoreBoardDashboard {
  final String semester;            // Học kỳ
  final ClassSubjectInfo classInfo; // Thống kê chung phía trên
  final List<StudentScore> students;// Danh sách sinh viên trong bảng
  final int totalEntered;           // Tổng số lượng sinh viên đã được nhập điểm (45)
  final int currentPage;            // Trang hiện tại
  final int totalPages;             // Tổng số trang

  ScoreBoardDashboard({
    required this.semester,
    required this.classInfo,
    required this.students,
    required this.totalEntered,
    required this.currentPage,
    required this.totalPages,
  });
}
