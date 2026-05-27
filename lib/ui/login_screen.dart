import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../utils/theme_app.dart';

class LoginScreen extends StatefulWidget{
 const LoginScreen({super.key});

 @override
 State<LoginScreen> createState()=>_LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
 bool hienMK=false;
 final taiKhoanController=TextEditingController();
 final matKhauController=TextEditingController();
 final authService=AuthService();

 @override
 void dispose(){
  taiKhoanController.dispose();
  matKhauController.dispose();
  super.dispose();
 }

 InputDecoration oNhap({required String hint,required IconData icon,Widget? suffix}){
  return InputDecoration(
   hintText:hint,
   prefixIcon:Icon(icon,color:ThemeApp.mauChinh),
   suffixIcon:suffix,
   filled:true,
   fillColor:Colors.white,
   border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none),
  );
 }

 void xuLyDangNhap(){
  final tk=authService.dangNhap(taiKhoanController.text,matKhauController.text);

  if(tk==null){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Sai tài khoản hoặc mật khẩu")));
   return;
  }

  SessionService.luuDangNhap(tk);

  if(authService.laAdmin(tk)){
   Navigator.pushReplacementNamed(context,"/admin");
  }else{
   Navigator.pushReplacementNamed(context,"/home");
  }
 }

 @override
 Widget build(BuildContext context){
  return Scaffold(
   backgroundColor:ThemeApp.mauNen,
   body:SafeArea(
    child:SingleChildScrollView(
     padding:const EdgeInsets.all(24),
     child:Column(
      children:[
       const SizedBox(height:45),
       Container(
        width:118,height:118,
        decoration:BoxDecoration(color:ThemeApp.mauPhu,borderRadius:BorderRadius.circular(32),boxShadow:const [BoxShadow(color:Color(0x15000000),blurRadius:12,offset:Offset(0,5))]),
        child:const Icon(Icons.school_rounded,size:62,color:ThemeApp.mauIcon),
       ),
       const SizedBox(height:25),
       const Text("QUẢN LÝ HỌC TẬP",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:ThemeApp.chuDam)),
       const Text("SINH VIÊN CÁ NHÂN",style:TextStyle(fontSize:18,fontWeight:FontWeight.w600,color:ThemeApp.mauChinh)),
       const SizedBox(height:10),
       const Text("Đăng nhập để tiếp tục",style:TextStyle(color:ThemeApp.chuPhu)),
       const SizedBox(height:35),
       TextField(controller:taiKhoanController,decoration:oNhap(hint:"Nhập tài khoản",icon:Icons.person_rounded)),
       const SizedBox(height:18),
       TextField(
        controller:matKhauController,
        obscureText:!hienMK,
        decoration:oNhap(
         hint:"Nhập mật khẩu",
         icon:Icons.lock_rounded,
         suffix:IconButton(
          onPressed:()=>setState(()=>hienMK=!hienMK),
          icon:Icon(hienMK?Icons.visibility_rounded:Icons.visibility_off_rounded,color:ThemeApp.chuPhu),
         ),
        ),
       ),
       const SizedBox(height:35),
       SizedBox(
        width:double.infinity,height:58,
        child:ElevatedButton(
         onPressed:xuLyDangNhap,
         style:ElevatedButton.styleFrom(backgroundColor:ThemeApp.mauChinh,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
         child:const Text("ĐĂNG NHẬP",style:TextStyle(fontSize:18,color:Colors.white,fontWeight:FontWeight.bold)),
        ),
       ),
       const SizedBox(height:14),
       TextButton(onPressed:()=>Navigator.pushNamed(context,"/forgot-password"),child:const Text("Quên mật khẩu?")),
       const SizedBox(height:12),
       const Text("Version 1.0",style:TextStyle(color:ThemeApp.chuPhu)),
      ],
     ),
    ),
   ),
  );
 }
}

