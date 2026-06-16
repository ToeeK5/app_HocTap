class HocKy {
  final String id;
  final String tenHocKy; // Ví dụ: "Học kỳ 1", "Học kỳ 2"
  final int value;       // Số nguyên: 1, 2, 3... để tính toán logic

  HocKy({required this.id, required this.tenHocKy, required this.value});

  factory HocKy.fromFirestore(String id, Map<String, dynamic> data) {
    // Ép kiểu an toàn: nếu là String thì parse sang int, nếu đã là int thì giữ nguyên
    final rawValue = data['value'];
    int parsedValue = 1;
    if (rawValue is int) {
      parsedValue = rawValue;
    } else if (rawValue is String) {
      parsedValue = int.tryParse(rawValue) ?? 1;
    }

    return HocKy(
      id: id,
      tenHocKy: data['tenHocKy'] ?? '',
      value: parsedValue, 
    );
  }

  Map<String, dynamic> toMap() => {'tenHocKy': tenHocKy, 'value': value};
}