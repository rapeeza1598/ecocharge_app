import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/charging_session.dart';
import '../models/me.dart';
import 'chareing_screen2.dart';

class BoothDetailScreen extends StatefulWidget {
  final String boothName;
  final String boothId;
  final String status;
  // final double money;
  const BoothDetailScreen(this.boothId, this.boothName, this.status,
      {super.key});

  @override
  State<BoothDetailScreen> createState() => _BoothDetailScreenState();
}

class _BoothDetailScreenState extends State<BoothDetailScreen> {
  String boothName = '';
  String boothId = '';
  String status = '';
  int _value = 1;
  MqttServerClient? client;
  String message = '';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  Me? me;
  ChargingSession? chargingSession;
  final Dio _dio = Dio();
  String token = '';
  TextEditingController moneyController = TextEditingController();

  @override
  void initState() {
    _getUser();
    super.initState();
    connect();
  }

  void _getUser() async {
    token = (await _secureStorage.read(key: 'access_token'))!;
    final responseUser = await _dio.get(
      'https://ecocharge.azurewebsites.net/user/me',
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );
    me = Me.fromJson(responseUser.data);
  }

  @override
  void dispose() {
    client!.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Booth Detail'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange,
                        width: 5,
                      ),
                      // shadow outside the box
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 10,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.ev_station,
                            size: 90.0,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 15),
                Text(
                  'Booth Name: ${widget.boothName}',
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // const Text(
                //   'Location',
                //   style: TextStyle(fontSize: 16.0),
                // ),
                // const SizedBox(height: 10),
                Text(
                  'Status: ${widget.status}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Power: 22 kW',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Price: 7.7 Baht/kWh',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.orange,
                      width: 2,
                    ),
                    // shadow outside the box
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          // radio button for charging full or charging by money horizontally
                          const Text(
                            'Charging Method',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          RadioListTile(
                            title: const Text('Charging Full'),
                            value: 1,
                            groupValue: _value,
                            onChanged: (value) {
                              setState(() {
                                _value = value as int;
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text('Charging by Money'),
                            value: 2,
                            groupValue: _value,
                            onChanged: (value) {
                              setState(() {
                                _value = value as int;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // const Spacer(),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (me!.balance < 10) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Warning'),
                                  content: const Text(
                                      'Your balance is not enough to charge'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              if (_value == 1) {
                                try {
                                  EasyLoading.show(status: 'Starting...');
                                  // delay 2 seconds
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      print('delay 2 seconds');
                                    },
                                  );
                                  await _getSessionsId();
                                  await publishMessage(
                                      'charging/${widget.boothId}',
                                      '{"boothId":"${widget.boothId}","sessionsId":"${chargingSession?.id}","money":${me?.balance},"command":"start"}');
                                  await _goChargingScreen();
                                  EasyLoading.dismiss();
                                } catch (error) {
                                  print(widget.boothId);
                                  print(error);
                                  EasyLoading.showError(
                                      'Failed to start charging');
                                }
                              } else {
                                // select amount of money to charge button and textfield number check balance
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title:
                                              const Text('Charging by Money'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                  'Enter amount of money:'),
                                              const SizedBox(height: 10),
                                              TextField(
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Amount of money',
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                controller: moneyController,
                                                onChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    if (int.parse(value) >
                                                        me!.balance) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Warning'),
                                                          content: const Text(
                                                              'Your balance is not enough to charge'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    EasyLoading.show(
                                                        status: 'Starting...');
                                                    await Future.delayed(
                                                      const Duration(
                                                          seconds: 2),
                                                      () {
                                                        print(
                                                            'delay 2 seconds');
                                                      },
                                                    );
                                                    await _getSessionsId();
                                                    await publishMessage(
                                                        'charging/${widget.boothId}',
                                                        '{"boothId":"${widget.boothId}","sessionsId":"${chargingSession?.id}","money":${moneyController.text},"command":"start"}');
                                                    await _goChargingScreen();
                                                    EasyLoading.dismiss();
                                                  } catch (error) {
                                                    print(widget.boothId);
                                                    print(error);
                                                    EasyLoading.showError(
                                                        'Failed to start charging');
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange,
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                child: const Text(
                                                    'Start Charging',
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.all(20),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Start Charging',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void connect() async {
    client = MqttServerClient('broker.hivemq.com', '');
    client!.port = 1883;
    client!.logging(on: true);

    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;
    client!.onUnsubscribed = onUnsubscribed as void Function(String?)?;
    client!.onSubscribeFail = onSubscribeFail;
    client!.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .keepAliveFor(60)
        .startClean()
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
    } catch (e) {
      print('Exception: $e');
      client!.disconnect();
    }
  }

  void onConnected() {
    print('Connected');
    client!.subscribe('charging/${widget.boothId}', MqttQos.atLeastOnce);
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      setState(() {
        this.message = payload;
      });
    });
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void onUnsubscribed(String? topic) {
    print('Unsubscribed from topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('Failed to subscribe to topic: $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  publishMessage(String topic, String message) async {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  Future<void> _goChargingScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChargingScreen2(
          boothId: widget.boothId,
          sessionId: chargingSession!.id,
        ),
      ),
    );
  }

  _getSessionsId() async {
    final response = await _dio.post(
      'https://ecocharge.azurewebsites.net/charging_sessions/',
      data: {
        'boothId': widget.boothId,
      },
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );
    chargingSession = ChargingSession.fromJson(response.data);
  }
}
