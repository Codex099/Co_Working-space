import 'package:flutter/material.dart';
import 'package:flutter_projet_tutore/bottomNavBar/balance.dart';
import 'package:flutter_projet_tutore/bottomNavBar/reservations.dart';
import 'package:flutter_projet_tutore/bottomNavBar/settings.dart';
import 'package:flutter_projet_tutore/bottomNavBar/home_page.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int selectedIndex = 1;
  void navigation(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<Widget> pages = [
    BalanceScreen(),
    HomePage(),
    ReservationsScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: selectedIndex,
            onTap: navigation,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.fromARGB(255, 46, 104, 69),
            unselectedItemColor: const Color.fromARGB(255, 120, 120, 120),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 32),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_rounded, size: 28),
                label: 'Balance',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.event_note,
                  size: 28,
                ), // Changed icon for Bookings
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_box_rounded, size: 28),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
