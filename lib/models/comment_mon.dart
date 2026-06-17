import 'package:cloud_firestore/cloud_firestore.dart';

class CommentMon {
  final String id;
  final String maMon;
  final String maSV;
  final String tenSinhVien;
  final String noiDung;
  final DateTime ngayTao;
  final String? anhUrl;
  final String? anhBase64;

  CommentMon({
    required this.id,
    required this.maMon,
    required this.maSV,
    required this.tenSinhVien,
    required this.noiDung,
    required this.ngayTao,
    this.anhUrl,
    this.anhBase64,
  });

  factory CommentMon.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawDate = data['ngayTao'];

    DateTime ngayTao;
    if (rawDate is Timestamp) {
      ngayTao = rawDate.toDate();
    } else {
      ngayTao = DateTime.now();
    }

    return CommentMon(
      id: id,
      maMon: data['maMon'] ?? '',
      maSV: data['maSV'] ?? '',
      tenSinhVien: data['tenSinhVien'] ?? '',
      noiDung: data['noiDung'] ?? '',
      ngayTao: ngayTao,
      anhUrl: data['anhUrl'],
      anhBase64: data['anhBase64'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'maMon': maMon,
      'maSV': maSV,
      'tenSinhVien': tenSinhVien,
      'noiDung': noiDung,
      'ngayTao': Timestamp.fromDate(ngayTao),
      'anhUrl': anhUrl,
      'anhBase64': anhBase64,
    };
  }
}