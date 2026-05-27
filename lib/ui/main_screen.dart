import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'schedule/schedule_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int viTriDangChon = 0;

  final List<Widget> danhSachManHinh = const [
    HomeScreen(),
    ScheduleScreen(),
  ];

  void xuLyChonTab(int viTri) {
    if (viTri == 0 || viTri == 1) {
      setState(() {
        viTriDangChon = viTri;
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: danhSachManHinh[viTriDangChon],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viTriDangChon,
        onTap: xuLyChonTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Thời khóa biểu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Xem điểm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}