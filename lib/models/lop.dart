
class Lop {
  final String id;
  final String tenLop;

  Lop({required this.id, required this.tenLop});

  factory Lop.fromFirestore(String id, Map<String, dynamic> data) {
    return Lop(
      id: id,
      tenLop: data['tenlop'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'tenlop': tenLop};
}