import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/comment_mon.dart';
import '../services/session_service.dart';
import '../utils/theme_app.dart';

class CommentItem extends StatelessWidget {
  final CommentMon comment;
  final VoidCallback onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final laChuBai =
        comment.maSV == SessionService.layMaSV();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF8FCFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemeApp.mauVien,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
              const SizedBox(width: 10),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.tenSinhVien,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${comment.ngayTao.day}/${comment.ngayTao.month}/${comment.ngayTao.year}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (laChuBai)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ================= CONTENT =================
          Text(
            comment.noiDung,
            style: const TextStyle(fontSize: 14),
          ),

          // ================= IMAGE (FIX 1 ẢNH DUY NHẤT) =================
          if (comment.anhBase64 != null &&
              comment.anhBase64!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(comment.anhBase64!),
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (comment.anhUrl != null &&
              comment.anhUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  comment.anhUrl!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}