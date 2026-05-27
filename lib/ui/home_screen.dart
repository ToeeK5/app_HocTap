import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../widgets/bottom_nav_app.dart';
import '../utils/theme_app.dart';

class HomeScreen extends StatelessWidget{
 const HomeScreen({super.key});

 @override
 Widget build(BuildContext context){
  final maSV=SessionService.layMaSV();

  return Scaffold(
   backgroundColor:ThemeApp.mauNen,
   appBar:AppBar(title:const Text("Home"),backgroundColor:ThemeApp.mauNen,foregroundColor:ThemeApp.chuDam,elevation:0),
   body:Padding(
    padding:const EdgeInsets.all(18),
    child:Column(
     crossAxisAlignment:CrossAxisAlignment.start,
     children:[
      Text("Xin chao, $maSV",style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:ThemeApp.chuDam)),
      const SizedBox(height:12),
      Container(
       width:double.infinity,
       padding:const EdgeInsets.all(18),
       decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),border:Border.all(color:ThemeApp.mauVien)),
       child:const Text("Man hinh trang chu dang de trong de thanh vien khac lam.",style:TextStyle(color:ThemeApp.chuPhu)),
      ),
     ],
    ),
   ),
   bottomNavigationBar:const BottomNavApp(currentIndex:0),
  );
 }
}
