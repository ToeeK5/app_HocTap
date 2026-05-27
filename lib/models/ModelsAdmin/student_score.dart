enum PassingStatus { passed, failed, notEntered }

class StudentScore {
  final int index;             // STT
  final String studentId;      // MSSV
  final String fullName;       // Họ và Tên
  final double? midtermScore;  // Điểm Giữa kỳ (0.4)
  final double? finalScore;    // Điểm Cuối kỳ (0.6)
  
  // Thuộc tính phục vụ UI: Xác định dòng này đang được nhấn "Sửa" hay không
  final bool isEditing;        

  StudentScore({
    required this.index,
    required this.studentId,
    required this.fullName,
    this.midtermScore,
    this.finalScore,
    this.isEditing = false, // Mặc định ban đầu là không chỉnh sửa
  });

  // Getter tự động tính ĐTB theo hệ số mới: Giữa kỳ * 0.4 + Cuối kỳ * 0.6
  double? get averageScore {
    if (midtermScore == null || finalScore == null) return null;
    double score = (midtermScore! * 0.4) + (finalScore! * 0.6);
    return double.parse(score.toStringAsFixed(1));
  }

  // Tự động phân loại Trạng thái
  PassingStatus get status {
    if (midtermScore == null || finalScore == null) {
      return PassingStatus.notEntered;
    }
    return averageScore! >= 4.0 ? PassingStatus.passed : PassingStatus.failed;
  }

  // Hàm copyWith giúp dễ dàng thay đổi trạng thái điểm hoặc trạng thái bấm nút "Sửa" trên UI
  StudentScore copyWith({
    double? midtermScore,
    double? finalScore,
    bool? isEditing,
  }) {
    return StudentScore(
      index: this.index,
      studentId: this.studentId,
      fullName: this.fullName,
      midtermScore: midtermScore ?? this.midtermScore,
      finalScore: finalScore ?? this.finalScore,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}
