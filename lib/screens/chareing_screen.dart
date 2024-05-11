
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/charging_booth.dart';
import '../models/charging_session.dart';
import '../models/me.dart';

class PowerUsageScreen extends StatefulWidget {
  final ChargingBooth chargingBooth;

  const PowerUsageScreen(this.chargingBooth, {super.key});

  @override
  _PowerUsageScreenState createState() => _PowerUsageScreenState();
}

class _PowerUsageScreenState extends State<PowerUsageScreen> {
  final dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int powerUsage = 0;
  int timeCounter = 0;
  double moneySpent = 0.0;
  late final Me me;
  late ChargingSession chargingSession;
  // late MqttServerClient client;
  WebSocketChannel? channel;
  bool isCharging = false;

  @override
  void initState() {
    super.initState();
    // _initAsync();
    // channel = WebSocketChannel.connect(
    //     Uri.parse(
    //         'wss://ecocharge.azurewebsites.net/charging_sessions/ws/${widget.chargingBooth.boothId}/'));
    // print(widget.chargingBooth);
  }

  Future<void> _initAsync() async {
    await _getMe();
    createCession();
  }

  Future<void> createCession() async {
    try {
      final response = await dio.post(
        'https://ecocharge.azurewebsites.net/charging_sessions/',
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization':
              'Bearer ${await _secureStorage.read(key: 'access_token')}'
        }),
        data: {
          "userId": me.id,
          'booth_id': widget.chargingBooth.boothId,
        },
      );
      if (response.statusCode == 200) {
        chargingSession = ChargingSession.fromJson(response.data);
        print(chargingSession.id);
        // boothId connect to websocket wss://ecocharge.azurewebsites.net/charging_sessions/ws/$boothId
        //data response {"boothId":"df859aad-20db-4454-82fb-9f121c3fc73b","sessionsId":"4e77ef5f-021c-4e68-872e-cdfb4b0e6aab","power":"1.30","action":"start"}
        channel!.stream.listen((event) {
          print(event);
          final data = event.toString();
          if (data.contains('start')) {
            isCharging = true;
            print('Start charging');
          } else if (data.contains('stop')) {
            isCharging = false;
            print('Stop charging');
          } else {
            final power = double.parse(data.split(',')[2].split(':')[1]);
            final action = data.split(',')[3].split(':')[1];
            if (action == 'start') {
              setState(() {
                powerUsage = power.toInt();
                timeCounter++;
                moneySpent += power * widget.chargingBooth.chargingRate;
              });
            }
          }
        });
      }
       else {
        print('Failed to create charging session');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _getMe() async {
    try {
      final response =
          await dio.get('https://ecocharge.azurewebsites.net/user/me',
              options: Options(headers: {
                'accept': 'application/json',
                'Authorization':
                    'Bearer ${await _secureStorage.read(key: 'access_token')}'
              }));
      if (response.statusCode == 200) {
        me = Me.fromJson(response.data);
        print('Me: $me');
      } else {
        print('Failed to get me');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // You can use widget.chargingBooth here as well to access chargingBooth details
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Usage Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // random power usage
            Text('Power Usage: $powerUsage W'),
            Text('Time: $timeCounter s'),
            Text('Money Spent: $moneySpent THB'),
            ElevatedButton(
              onPressed: () {
                // Stop or change the charging
                _stopOrChange();
              },
              child: const Text('Stop or Change'),
            )
          ],
        ),
      ),
    );
  }

  void _stopOrChange() {
    Navigator.pop(context);
  }

  void _startCharging() {}
}
