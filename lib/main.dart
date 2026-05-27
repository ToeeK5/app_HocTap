import 'package:flutter/material.dart';

import 'ui/login_screen.dart';
import 'ui/home_screen.dart';
import 'ui/lich_hoc_screen.dart';
import 'ui/diem_screen.dart';
import 'ui/profile_screen.dart';
import 'ui/admin_screen.dart';
import 'ui/forgot_password_screen.dart';
import 'ui/reset_password_screen.dart';
import 'utils/theme_app.dart';

void main(){
 runApp(const MyApp());
}

class MyApp extends StatelessWidget{
 const MyApp({super.key});

 Route<dynamic> _khongHieuUng(Widget man){
  return PageRouteBuilder(
   pageBuilder:(_,__,___)=>man,
   transitionDuration:Duration.zero,
   reverseTransitionDuration:Duration.zero,
  );
 }

 @override
 Widget build(BuildContext context){
  return MaterialApp(
   debugShowCheckedModeBanner:false,
   title:"Quản Lý Học Tập",
   theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:ThemeApp.mauNen),
   initialRoute:"/login",
   onGenerateRoute:(settings){
    if(settings.name=="/login")return _khongHieuUng(const LoginScreen());
    if(settings.name=="/home")return _khongHieuUng(const HomeScreen());
    if(settings.name=="/lichhoc")return _khongHieuUng(const LichHocScreen());
    if(settings.name=="/diem")return _khongHieuUng(const DiemScreen());
    if(settings.name=="/profile")return _khongHieuUng(const ProfileScreen());
    if(settings.name=="/admin")return _khongHieuUng(const AdminScreen());    if(settings.name=="/forgot-password")return _khongHieuUng(const ForgotPasswordScreen());   if(settings.name=="/reset-password")return _khongHieuUng(const ResetPasswordScreen());
    return _khongHieuUng(const LoginScreen());
   },
  );
 }
}

