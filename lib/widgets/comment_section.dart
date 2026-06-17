import 'package:flutter/material.dart';

import '../models/comment_mon.dart';
import '../services/comment_service.dart';
import '../services/session_service.dart';
import '../services/sinh_vien_service.dart';
import 'comment_item.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
class CommentSection extends StatefulWidget {
  final String maMon;

  const CommentSection({super.key, required this.maMon});

  @override
  State<CommentSection> createState() => _CommentSectionState();
  
}

class _CommentSectionState extends State<CommentSection> {
  final commentController = TextEditingController();
final picker = ImagePicker();
String? anh64;
Uint8List? anhDaChon;
String? tenAnh;
  bool moRong = false;

  final commentService = CommentService();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

 Future<void> _guiComment() async {
  final noiDung =
      commentController.text.trim();

  if (noiDung.isEmpty &&
      anh64 == null) {
    return;
  }

  final maSV =
      SessionService.layMaSV();

  final sinhVien =
      await SinhVienService()
          .laySinhVienTheoMa(maSV);

  if (sinhVien == null) return;

  final comment = CommentMon(
    id: "",
    maMon: widget.maMon,
    maSV: maSV,
    tenSinhVien: sinhVien.hoTen,
    noiDung: noiDung,
    ngayTao: DateTime.now(),
    anhUrl: null,
    anhBase64: anh64,
  );

  await commentService.themComment(
      comment);

  commentController.clear();

  setState(() {
    anhDaChon = null;
    tenAnh = null;
    anh64 = null;
  });
}

Future<void> _chonAnh() async {
  final XFile? file =
      await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (file == null) return;

  final bytes =
      await file.readAsBytes();

  setState(() {
    anhDaChon = bytes;
    tenAnh = file.name;
    anh64 = base64Encode(bytes);
  });
}
 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommentMon>>(
      stream: commentService.layCommentTheoMon(widget.maMon),
      builder: (context, snapshot) {
  if (snapshot.hasError) {
    print(snapshot.error);
    return Text(
      'Lỗi: ${snapshot.error}',
      style: const TextStyle(color: Colors.red),
    );
  }

  if (snapshot.connectionState ==
      ConnectionState.waiting) {
    return const CircularProgressIndicator();
  }

  final ds = snapshot.data ?? [];

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    moRong = !moRong;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.comment_rounded),
                      const SizedBox(width: 8),
                      Text(
                        "Bình luận (${ds.length})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        moRong
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),

              if (moRong) ...[
                const SizedBox(height: 10),

                TextField(
                  controller: commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Viết bình luận...",
                    filled: true,
                    fillColor: const Color(0xffF8FCFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _guiComment,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ),
const SizedBox(height: 10),

Row(
  children: [
    ElevatedButton.icon(
      onPressed: _chonAnh,
      icon: const Icon(Icons.image),
      label: const Text(
        "Chọn ảnh",
      ),
    ),

    const SizedBox(width: 10),

    if (tenAnh != null)
      Expanded(
        child: Text(
          tenAnh!,
          overflow:
              TextOverflow.ellipsis,
        ),
      ),
  ],
),
if (anhDaChon != null)
  Padding(
    padding:
        const EdgeInsets.only(
      top: 10,
    ),
    child: ClipRRect(
      borderRadius:
          BorderRadius.circular(12),
      child: Image.memory(
        anhDaChon!,
        height: 150,
      ),
    ),
  ),
                const SizedBox(height: 12),

                if (ds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Chưa có bình luận",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                ...ds.map(
                  (c) => CommentItem(
                    comment: c,
                    onDelete: () async {
                      await commentService.xoaComment(c.id);
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
