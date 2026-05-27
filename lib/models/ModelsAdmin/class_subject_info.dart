class ClassSubjectInfo {
  final String subjectName;       // Môn học (e.g., "Cấu trúc dữ liệu và giải thuật")
  final String className;         // Lớp học (e.g., "CTK44-A")
  final double midtermWeight;     // Hệ số giữa kỳ (e.g., 0.4)
  final double finaltermWeight;   // Hệ số cuối kỳ (e.g., 0.6)
  final int totalStudents;        // Tổng số SV (e.g., 45)
  final double classAverageScore; // ĐTB Lớp (e.g., 7.8)

  ClassSubjectInfo({
    required this.subjectName,
    required this.className,
    required this.midtermWeight,
    required this.finaltermWeight,
    required this.totalStudents,
    required this.classAverageScore,
  });
}
