import 'package:flutter/material.dart';
import '../widgets/bottom_nav_app.dart';
import '../utils/theme_app.dart';

class LichHocScreen extends StatelessWidget{
 const LichHocScreen({super.key});

 @override
 Widget build(BuildContext context){
  return const Scaffold(
   backgroundColor:ThemeApp.mauNen,
   body:Center(child:Text("Man hinh lich hoc",style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:ThemeApp.chuDam))),
   bottomNavigationBar:BottomNavApp(currentIndex:1),
  );
 }
}
