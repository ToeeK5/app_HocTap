import 'package:flutter/material.dart';
import '../utils/theme_app.dart';

class BottomNavApp extends StatelessWidget{
 final int currentIndex;
 const BottomNavApp({super.key,required this.currentIndex});

 @override
 Widget build(BuildContext context){
  return BottomNavigationBar(
   currentIndex:currentIndex,
   type:BottomNavigationBarType.fixed,
   backgroundColor:Colors.white,
   selectedItemColor:ThemeApp.mauChinh,
   unselectedItemColor:Colors.grey,
   selectedLabelStyle:const TextStyle(fontWeight:FontWeight.bold),
   onTap:(index){
    if(index==currentIndex)return;
    if(index==0)Navigator.pushReplacementNamed(context,"/home");
    if(index==1)Navigator.pushReplacementNamed(context,"/lichhoc");
    if(index==2)Navigator.pushReplacementNamed(context,"/diem");
    if(index==3)Navigator.pushReplacementNamed(context,"/profile");
   },
   items:const[
    BottomNavigationBarItem(icon:Icon(Icons.home_rounded),label:"Trang chủ"),
    BottomNavigationBarItem(icon:Icon(Icons.calendar_month_rounded),label:"Lịch"),
    BottomNavigationBarItem(icon:Icon(Icons.bar_chart_rounded),label:"Điểm"),
    BottomNavigationBarItem(icon:Icon(Icons.person_rounded),label:"Profile"),
   ],
  );
 }
}
