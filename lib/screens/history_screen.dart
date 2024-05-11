import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../models/history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _dio = Dio();
  List<History> history = [];
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool isLoading = false;

  void fetchHistory() async {
    String? userId = await _secureStorage.read(key: 'id');
    try {
      final response = await _dio.get(
          'https://ecocharge.azurewebsites.net/charging_sessions/users/$userId',
          options: Options(headers: {
            'accept': 'application/json',
            'Authorization':
                'Bearer ${await _secureStorage.read(key: 'access_token')}'
          }));
      final List<dynamic> responseData = response.data;
      setState(() {
        history = responseData
            .map((e) => History.fromJson(e as Map<String, dynamic>))
            .toList();
        isLoading = true;
      });
    } on DioError catch (e) {
      print(e);
      if (e.response!.statusCode == 404 &&
          e.response!.data['detail'] == 'Charging Session not found') {
        setState(() {
          isLoading = true;
        });
      }
    }
  }

  @override
  void initState() {
    fetchHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator(
        child: historyList(),
        onRefresh: () async {
          await Future.delayed(
            const Duration(seconds: 2),
            () {
              fetchHistory();
            },
          );
        },
      ),
    ));
  }

  Widget historyList() {
    if (!isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (isLoading && history.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('No history',
                style: TextStyle(fontSize: 20.0, color: Colors.grey)),
          )
        ],
      );
    }
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        // sort by current date
        history.sort((a, b) => b.startTime.compareTo(a.startTime));
        return Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            // 2024-04-03 03:17:44.467060 to HH:mm day MM yyyy
            title: Text('Booth ${history[index].boothName}'),
            subtitle: Text(convertDate(
                DateTime.parse(history[index].startTime.toString()))),
            // trailing: const Icon(Icons.map),
            onTap: () {},
            trailing: Text(
                '- ${(history[index].powerUsed * 7.7).toStringAsFixed(2)} ฿'),
          ),
        );
      },
    );
  }

  String convertDate(DateTime date) {
    final DateFormat formatter = DateFormat('HH:mm EEE, d MMM yyyy');
    return formatter.format(date.toLocal());
  }
}
