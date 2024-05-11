import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttMessageScreen extends StatefulWidget {
  @override
  _MqttMessageScreenState createState() => _MqttMessageScreenState();
}

class _MqttMessageScreenState extends State<MqttMessageScreen> {
  MqttServerClient? client;
  String message = '';

  @override
  void initState() {
    super.initState();
    connect();
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
    client!.subscribe('charging/df859aad-20db-4454-82fb-9f121c3fc73b', MqttQos.atLeastOnce);
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

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
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
        title: Text('MQTT Message Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Received Message:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                publishMessage('charging/df859aad-20db-4454-82fb-9f121c3fc73b', '{"boothId":"df859aad-20db-4454-82fb-9f121c3fc73b","sessionsId":"f576a9bb-a8f1-46e2-9935-b6d3aaa9f3a8","money":1000.0,"command":"start"}');
              },
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}