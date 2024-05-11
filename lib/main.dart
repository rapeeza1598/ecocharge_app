import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'screens/account_screen.dart';
import 'screens/booth_detail_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home.dart';
import 'screens/introduction.dart';
import 'screens/otp.dart';
import 'screens/recent_transaction_screen.dart';
import 'screens/regiter_screen.dart';
import 'screens/scan_qr_code_screen.dart';
import 'screens/securityPrivacy.dart';
import 'screens/signIn_screen.dart';
import 'screens/station_screen.dart';
import 'screens/topup_screen.dart';
import 'screens/userAgreement.dart';
import 'screens/wallet_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EV Charging App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.orange),
      ),
      home: const IntroductionScreenPage(),
      // home: BoothDetailScreen('dqdjqp', 'dqdq','online'),
      builder: EasyLoading.init(),
      routes: {
        '/login': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
        '/station': (context) => const StationScreen(),
        '/scan_qr_code': (context) => const ScanQRCodeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/account': (context) => const AccountScreen(),
        '/register': (context) => const RegisterScreen(),
        '/wallet': (context) => const MyWallet(),
        '/topup': (context) => const TopUpScreen(),
        '/recent_transaction': (context) => const RecentTransactionScreen(),
        '/forgot-password':(context) => const ForgotPasswordScreen(),
        '/security-privacy':(context) => const SecurityAndPrivacy(),
        '/user-agreement':(context) => const UserAgreementScreen(),
      },
    );
  }
}
