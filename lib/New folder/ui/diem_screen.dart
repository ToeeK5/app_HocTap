import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../services/diem_service.dart';
import '../utils/tinh_toan_hoc_tap.dart';
import '../utils/theme_app.dart';
import '../widgets/bottom_nav_app.dart';
import '../utils/mau_hoc_tap.dart';

class DiemScreen extends StatefulWidget{
 const DiemScreen({super.key});

 @override
 State<DiemScreen> createState()=>_DiemScreenState();
}

class _DiemScreenState extends State<DiemScreen>{
 final timController=TextEditingController();

 @override
 void dispose(){
  timController.dispose();
  super.dispose();
 }

 @override
 Widget build(BuildContext context){
  final maSV=SessionService.layMaSV();
  final dsGoc=DiemService().layDiemTheoSinhVien(maSV);
  final tuKhoa=timController.text.toLowerCase();

  final dsDiem=dsGoc.where((item){
   final ten=item.monHoc.tenMon.toLowerCase();
   final ma=item.monHoc.maMon.toLowerCase();
   return ten.contains(tuKhoa)||ma.contains(tuKhoa);
  }).toList();

  final tongTin=TinhToanHocTap.tinhTongTin(dsGoc);
  final gpa10=TinhToanHocTap.tinhGPAHe10(dsGoc);

  return Scaffold(
   backgroundColor:ThemeApp.mauNen,
   appBar:AppBar(
    title:const Text("Diem hoc tap"),
    backgroundColor:ThemeApp.mauNen,
    foregroundColor:ThemeApp.chuDam,
    elevation:0,
   ),
   body:SafeArea(
    child:SingleChildScrollView(
     padding:const EdgeInsets.all(16),
     child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children:[
       Row(
        children:[
         Expanded(child:_theTongKet("Tong tin", "$tongTin", Icons.confirmation_number_rounded)),
         const SizedBox(width:12),
         Expanded(child:_theTongKet("Diem TB /10", "$gpa10", Icons.star_rounded)),
        ],
       ),

       const SizedBox(height:16),

       TextField(
        controller:timController,
        onChanged:(value)=>setState((){}),
        decoration:InputDecoration(
         hintText:"Tim mon hoc",
         prefixIcon:const Icon(Icons.search_rounded,color:ThemeApp.mauIcon),
         filled:true,
         fillColor:Colors.white,
         border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none),
        ),
       ),

       const SizedBox(height:18),

       const Text(
        "Danh sach mon hoc",
        style:TextStyle(fontSize:19,fontWeight:FontWeight.bold,color:ThemeApp.chuDam),
       ),

       const SizedBox(height:12),

       if(dsDiem.isEmpty)
        const Center(
         child:Padding(
          padding:EdgeInsets.all(30),
          child:Text("Khong co mon hoc",style:TextStyle(color:ThemeApp.chuPhu)),
         ),
        ),

       ...dsDiem.map((item)=>_cardDiem(item)),
      ],
     ),
    ),
   ),
   bottomNavigationBar:const BottomNavApp(currentIndex:2),
  );
 }

 Widget _theTongKet(String title,String value,IconData icon){
  return Container(
   padding:const EdgeInsets.all(16),
   decoration:BoxDecoration(
    color:Colors.white,
    borderRadius:BorderRadius.circular(20),
    border:Border.all(color:ThemeApp.mauVien),
    boxShadow:const [BoxShadow(color:Color(0x11000000),blurRadius:8,offset:Offset(0,4))],
   ),
   child:Column(
    children:[
     Icon(icon,color:ThemeApp.mauIcon),
     const SizedBox(height:8),
     Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:ThemeApp.chuDam)),
     const SizedBox(height:4),
     Text(title,style:const TextStyle(fontSize:13,color:ThemeApp.chuPhu)),
    ],
   ),
  );
 }

 Widget _cardDiem(DiemMonHienThi item){
  return Container(
   margin:const EdgeInsets.only(bottom:14),
   padding:const EdgeInsets.all(16),
   decoration:BoxDecoration(
    color:Colors.white,
    borderRadius:BorderRadius.circular(22),
    border:Border.all(color:ThemeApp.mauVien),
    boxShadow:const [BoxShadow(color:Color(0x0F000000),blurRadius:8,offset:Offset(0,4))],
   ),
   child:Column(
    crossAxisAlignment:CrossAxisAlignment.start,
    children:[
     Row(
      children:[
       Container(
        width:46,
        height:46,
        decoration:BoxDecoration(color:ThemeApp.mauPhu,borderRadius:BorderRadius.circular(16)),
        child:const Icon(Icons.menu_book_rounded,color:ThemeApp.mauIcon),
       ),
       const SizedBox(width:12),
       Expanded(
        child:Column(
         crossAxisAlignment:CrossAxisAlignment.start,
         children:[
          Text(item.monHoc.tenMon,style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:ThemeApp.chuDam)),
          const SizedBox(height:3),
          Text("Ma mon: ${item.monHoc.maMon} - ${item.monHoc.soTinChi} tin",style:const TextStyle(color:ThemeApp.chuPhu)),
         ],
        ),
       ),
       Container(
        padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),
        decoration:BoxDecoration(color:MauHocTap.mauDiem(item.diemTongKet),borderRadius:BorderRadius.circular(14)),
        child:Text(item.diemTongKet.toStringAsFixed(1),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)),
       ),
      ],
     ),

     const SizedBox(height:16),

     Row(
      children:[
       Expanded(child:_oDiem("Giua ky", item.diem.diemGiuaKy.toStringAsFixed(1))),
       const SizedBox(width:10),
       Expanded(child:_oDiem("Cuoi ky", item.diem.diemCuoiKy.toStringAsFixed(1))),
       const SizedBox(width:10),
       Expanded(child:_oDiem("Tong", item.diemTongKet.toStringAsFixed(1))),
      ],
     ),
    ],
   ),
  );
 }

 Widget _oDiem(String title,String value){
  return Container(
   padding:const EdgeInsets.symmetric(vertical:10),
   decoration:BoxDecoration(color:const Color(0xffF8FCFF),borderRadius:BorderRadius.circular(14),border:Border.all(color:ThemeApp.mauVien)),
   child:Column(
    children:[
     Text(value,style:const TextStyle(fontSize:16,fontWeight:FontWeight.bold,color:ThemeApp.mauChinh)),
     const SizedBox(height:3),
     Text(title,style:const TextStyle(fontSize:12,color:ThemeApp.chuPhu)),
    ],
   ),
  );
 }
}

