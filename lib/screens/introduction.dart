import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionScreenPage extends StatefulWidget {
  const IntroductionScreenPage({super.key});

  @override
  IntroductionScreenPageState createState() => IntroductionScreenPageState();
}

class IntroductionScreenPageState extends State<IntroductionScreenPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  bool isGifPlaying = true;

  void handleGifFinished() {
    setState(() {
      isGifPlaying = false;
    });
  }

  @override
  void initState() {
    _loadToken();
    super.initState();
  }

  void _loadToken() async {
    final String? token = await _secureStorage.read(key: 'access_token');
    if (token != null) {
      final response = await _dio.get(
        'https://ecocharge.azurewebsites.net/user/me',
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  static const bodyStyle = TextStyle(fontSize: 16.0);
  static const pageDecoration = PageDecoration(
    titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
    bodyTextStyle: bodyStyle,
    bodyPadding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
    pageColor: Colors.white,
    imagePadding: EdgeInsets.zero,
  );
  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: "KMUTNB Ecocharge",
        body: "Make By ITI 27\nCopyright © 2024\nKing Mongkut's University of Technology North Bangkok",
        image: Image.asset("assets/images/kmutnb_logo.png", height: 350),
        decoration: pageDecoration.copyWith(
          imageFlex: 5,
          safeArea: 5,
          bodyFlex: 2,
          imageAlignment: Alignment.center,
        ),
      ),
      PageViewModel(
        title: "Find Charging Station",
        body: "Easy to find charging station",
        image: Image.asset("assets/images/City driver-pana.png"),
        decoration: pageDecoration.copyWith(
          imageFlex: 5,
          safeArea: 80,
          bodyFlex: 2,
          imageAlignment: Alignment.center,
        ),
      ),
      PageViewModel(
        title: "Scan QR Code",
        body: "Scan QR Code to start charging",
        image: Image.asset("assets/images/QR Code-bro.png", height: 350),
        decoration: pageDecoration.copyWith(
          imageFlex: 5,
          safeArea: 80,
          bodyFlex: 2,
          imageAlignment: Alignment.center,
        ),
      ),
      PageViewModel(
        title: "Are you ready?",
        body: "Let's get started!",
        image: Image.asset("assets/images/Carpool.gif"),
        footer: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/user-agreement');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ข้อตกลงและเงื่อนไข',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              Icon(Icons.arrow_forward, color: Colors.white, size: 20.0)
            ],
          ),
        ),
        decoration: pageDecoration.copyWith(
          imageFlex: 4,
          safeArea: 30,
          imageAlignment: Alignment.center,
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: getPages(),
      onDone: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      onSkip: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      allowImplicitScrolling: true,
      showSkipButton: true,
      skip: const Text("Skip"),
      done: const Text("Done"),
      next: const Icon(Icons.arrow_forward),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeColor: Colors.orange,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
      ),
    );
  }
}
