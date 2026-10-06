import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:vortex_iot_app/Rescuer/View/RescuerLogs.dart';
import 'package:vortex_iot_app/Rescuer/View/RescuerNotifications.dart';
import 'package:vortex_iot_app/Rescuer/View/RescuerOverviewPage.dart';
import 'package:vortex_iot_app/Rescuer/View/RescuerProfile.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  // 🔹 LIST THAT HOLDS YOUR PAGES
  final List<Widget> _pages = [
    const RescuerOverviewPage(), // index 0 → Home
    RescueNotificationPage(), // index 1
    const LogsPage(), // index 2
    const ProfilePage(), // index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // 🔹 PAGE SWITCHING HAPPENS HERE
      body: IndexedStack(index: _currentPage, children: _pages),

      // 🔹 BOTTOM NAV BAR
      bottomNavigationBar: DotCurvedBottomNav(
        scrollController: _scrollController,
        hideOnScroll: true,
        indicatorColor: Colors.orangeAccent,
        backgroundColor: Colors.orange,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.ease,
        selectedIndex: _currentPage,
        indicatorSize: 5,
        borderRadius: 25,
        height: 70,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: [
          Icon(
            Icons.home,
            color: _currentPage == 0 ? Colors.black : Colors.white,
          ),
          Icon(
            Icons.notifications_active,
            color: _currentPage == 1 ? Colors.black : Colors.white,
          ),
          Icon(
            Icons.color_lens,
            color: _currentPage == 2 ? Colors.black : Colors.white,
          ),
          Icon(
            Icons.person,
            color: _currentPage == 3 ? Colors.black : Colors.white,
          ),
        ],
      ),
    );
  }
}
