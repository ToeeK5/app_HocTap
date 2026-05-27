import 'package:flutter/material.dart';

class MauHocTap{
 static Color mauHocLuc(String hocLuc){
  if(hocLuc=="Gioi")return Colors.green;
  if(hocLuc=="Kha")return Colors.blue;
  if(hocLuc=="Trung binh")return Colors.orange;
  return Colors.red;
 }

 static Color mauDiem(double diem){
  if(diem>=8)return Colors.green;
  if(diem>=5)return Colors.orange;
  return Colors.red;
 }
}
