import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/charging_booth.dart';
import 'booth_detail_screen.dart';
import 'chareing_screen.dart';

class ScanQRCodeScreen extends StatefulWidget {
  const ScanQRCodeScreen({super.key});

  @override
  _ScanQRCodeScreenState createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // late QRViewController controller;
  final dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  @override
  void dispose() {
    // controller.dispose();
    MobileScannerController().dispose();
    super.dispose();
  }

  Future<void> fetchChargingStation(String boothId) async {
    try {
      EasyLoading.show(status: 'Fetching charging station...');
      final response = await dio.get(
          'https://ecocharge.azurewebsites.net/charging_booth/$boothId',
          options: Options(headers: {
            'accept': 'application/json',
            'Authorization':
                'Bearer ${await _secureStorage.read(key: 'access_token')}'
          }));
      if (response.statusCode == 200) {
        // print(response.data);
        ChargingBooth chargingBooth = ChargingBooth.fromJson(response.data);
        print(chargingBooth);
        EasyLoading.showSuccess('Charging station found');
        MobileScannerController().dispose();
        // delay for 1 second
        await Future.delayed(const Duration(seconds: 1));
        // builder: (context) => PowerUsageScreen(chargingBooth)));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BoothDetailScreen(
              chargingBooth.boothId,
              chargingBooth.boothName,
              chargingBooth.status,
            ),
          ),
        );
      } else {
        // controller.resumeCamera();
        EasyLoading.showError('Failed to fetch charging station');
      }
    } catch (error) {
      print(error);
      // controller.resumeCamera();
      EasyLoading.showError('Failed to fetch charging station');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 350.0;
    return AiBarcodeScanner(
      // validator: (value) {
      //   return value.startsWith('https://');
      // },
      canPop: false,
      onScan: (String value) {
        // debugPrint(value);
        // setState(() {
        //   print(value);
        // });
        fetchChargingStation(value);
      },
      onDetect: (p0) {},
      onDispose: () {
        // debugPrint("Barcode scanner disposed!");
        MobileScannerController().dispose();
      },
      controller: MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      ),
    );
  }
}
