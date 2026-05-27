import 'package:flutter/material.dart';

class MauHocTap{
 static Color mauHocLuc(String hocLuc){
  if(hocLuc=="Giỏi")return Colors.green;
  if(hocLuc=="Khá")return Colors.blue;
  if(hocLuc=="Trung bình")return Colors.orange;
  return Colors.red;
 }

 static Color mauDiem(double diem){
  if(diem>=8)return Colors.green;
  if(diem>=5)return Colors.orange;
  return Colors.red;
 }
}
