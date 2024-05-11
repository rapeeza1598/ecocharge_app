import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel channel;
  ReceivePort receivePort = ReceivePort();

  @override
  void initState() {
    super.initState();

    channel = WebSocketChannel.connect(
      Uri.parse('wss://ecocharge.azurewebsites.net/charging_sessions/ws/df859aad-20db-4454-82fb-9f121c3fc73b/'),
    );

    receivePort.listen((message) {
      // Handle messages received from isolates
      print('Received message: $message');
    });

    // Pass receivePort to isolate for communication
    Isolate.spawn(isolateFunction, receivePort.sendPort);
    // show websocket status
    channel.stream.listen((event) {
      print('WebSocket status: $event');
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    receivePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Demo'),
      ),
      body: Center(
        child: Text('WebSocket messages will appear here'),
      ),
    );
  }

  static void isolateFunction(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      // Handle messages received from main isolate
      print('Isolate received message: $message');
    });
  }
}
