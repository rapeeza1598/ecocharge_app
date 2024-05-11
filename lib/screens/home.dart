import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'history_screen.dart';
import 'scan_qr_code_screen.dart';
import 'station_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dio = Dio();
  final List<Widget> _screens = [
    const Center(
      child: Text(
        'Welcome to the EV Charging App!',
        style: TextStyle(fontSize: 20.0),
      ),
    ),
    const StationScreen(),
    const ScanQRCodeScreen(),
    const HistoryScreen(),
    const AccountScreen(),
  ];
  final List<String> _titles = [
    'Home',
    'Stations',
    'Scan QR Code',
    'Charging History',
    'Account'
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex],
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: _titles[0],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.ev_station),
              label: _titles[1],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              label: _titles[2],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: _titles[3],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: _titles[4],
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
