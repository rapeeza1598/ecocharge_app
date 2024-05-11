import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/mqttCommand.dart';
import '../models/websocketCommand.dart';

class ChargingScreen2 extends StatefulWidget {
  final String boothId;
  final String sessionId;
  const ChargingScreen2({super.key, required this.boothId, required this.sessionId});

  @override
  State<ChargingScreen2> createState() => _ChargingScreen2State();
}

class _ChargingScreen2State extends State<ChargingScreen2> {
  // double _energy = 0.0;
  // double _chargingTime = 0.0;
  double _totalCost = 0.0;
  double _power = 0.0;
  Timer? _timer;
  // bool _isRunning = false;
  int _start = 0;
  MqttServerClient? client;
  String message = '';
  late WebSocketChannel channel;
  ReceivePort receivePort = ReceivePort();

  void _startTimer() {
    // setState(() {
    //   _isRunning = true;
    // });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          _start++;
        });
      }
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    if (mounted) {
      // setState(() {
      //   _isRunning = false;
      // });
    }
  }

  @override
  void initState() {
    super.initState();
    connect();
    _startTimer();
    channel = WebSocketChannel.connect(
      Uri.parse(
          'wss://ecocharge.azurewebsites.net/charging_sessions/ws/${widget.boothId}/'),
    );

    receivePort.listen((message) {
      // Handle messages received from isolates
      print('Received message: $message');
    });

    // Pass receivePort to isolate for communication
    Isolate.spawn(isolateFunction, receivePort.sendPort);
    channel.stream.listen((message) {
      print('Received message: $message');
      WebsocketCommand websocketCommand = websocketCommandFromJson(message);
      _power = double.parse(websocketCommand.power);
      _totalCost = double.parse(websocketCommand.power) * 7.5;
    });
  }

  static void isolateFunction(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      // Handle messages received from main isolate
      print('Isolate received message: $message');
    });
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
    // 'charging/df859aad-20db-4454-82fb-9f121c3fc73b',
    // '{"boothId": "df859aad-20db-4454-82fb-9f121c3fc73b", "sessionsId": "df859aad-20db-4454-82fb-9f121c3fc73b", "money": 100.0, "command": "start"}'
    // send start command
    // String startCommand =
    //     '{"boothId": "df859aad-20db-4454-82fb-9f121c3fc73b", "sessionsId": "df859aad-20db-4454-82fb-9f121c3fc73b", "money": 100.0, "command": "start"}';
    // publishMessage(
    //     'charging/df859aad-20db-4454-82fb-9f121c3fc73b', startCommand);
    // log(startCommand);
    // publishMessage('charging/df859aad-20db-4454-82fb-9f121c3fc73b', '{"boothId":"df859aad-20db-4454-82fb-9f121c3fc73b","sessionsId":"f576a9bb-a8f1-46e2-9935-b6d3aaa9f3a8","money":1000.0,"command":"start"}');
  }

  void onConnected() {
    print('Connected');
    client!.subscribe(
        'charging/${widget.boothId}', MqttQos.atLeastOnce);
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print('Received message: $payload');
      MqttCommand mqttCommand = mqttCommandFromJson(payload);
      if (mqttCommand.command == 'stop') {
        _stopTimer();
        // publishMessage('charging/df859aad-20db-4454-82fb-9f121c3fc73b',
        //     '{"boothId": "df859aad-20db-4454-82fb-9f121c3fc73b", "sessionsId": "df859aad-20db-4454-82fb-9f121c3fc73b", "money": "0.0", "command": "stop"}');
        // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(100),
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orange,
                          width: 5,
                        ),
                      ),
                      child: const Center(
                          child: Icon(Icons.battery_charging_full_outlined,
                              size: 50, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Charging has been stopped',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false);
                      },
                      child: const Text('OK')),
                ],
              );
            });
      }
      // setState(() {
      //   this.message = payload;
      // });
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

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  void dispose() {
    // _timer?.cancel();
    _stopTimer();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Charging'),
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding: const EdgeInsets.all(14),
              child: Center(
                child: Column(
                  children: [
                    Container(
                        height: 200,
                        width: 200,
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 60.0,
                                color: Colors.orange,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _power.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text("kWh"),
                                ],
                              ),
                              const Text("Energy")
                            ],
                          ),
                        )),
                    const SizedBox(height: 50),
                    Container(
                      // decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(
                      //       color: Colors.orange,
                      //       width: 5,
                      //     ),
                      //   ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  // show 00:00 format
                                  Text(
                                    "${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text("Charging Time"),
                                ],
                              ),
                              // Column(
                              //   children: [
                              //     Text("$_energy kWh",
                              //         style: const TextStyle(
                              //             fontSize: 20,
                              //             fontWeight: FontWeight.bold)),
                              //     const Text("Energy"),
                              //   ],
                              // ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text("฿${_totalCost.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const Text("Total Cost"),
                                ],
                              ),
                              // Column(
                              //   children: [
                              //     Text("$_power kW",
                              //         style: const TextStyle(
                              //             fontSize: 20,
                              //             fontWeight: FontWeight.bold)),
                              //     const Text("Power"),
                              //   ],
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _endCharging(_totalCost),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.all(20),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('End Charging',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }

  _endCharging(double totalCost) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(100),
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange,
                        width: 5,
                      ),
                    ),
                    child: const Center(
                        child: Icon(Icons.battery_charging_full_outlined,
                            size: 50, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Are you sure you want to end charging?',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      publishMessage(
                          'charging/${widget.boothId}',
                          '{"boothId": "${widget.boothId}", "sessionsId": "${widget.sessionId}", "money": 1.0, "command": "stop"}');
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                    child: const Text('Confirm')),
              ],
            ));
  }
}
