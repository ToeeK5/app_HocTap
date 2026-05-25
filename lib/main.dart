import 'package:flutter/material.dart';
//Import thư viện Firebase.
import 'package:firebase_core/firebase_core.dart';
//Import file cấu hình mà FlutterFire tự tạo.
import 'firebase_options.dart';

void main() async {
  //Đảm bảo Flutter khởi tạo xong trước khi dùng Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  //Dòng này kết nối app với Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Firebase Demo"),
        ),
        body: const Center(
          child: Text("Firebase Connected"),
        ),
      ),
    );
  }
}