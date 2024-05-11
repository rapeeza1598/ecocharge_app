import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class RecentTransactionScreen extends StatefulWidget {
  const RecentTransactionScreen({super.key});

  @override
  State<RecentTransactionScreen> createState() => _RecentTransactionScreenState();
}

class _RecentTransactionScreenState extends State<RecentTransactionScreen> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Transaction> transactions = [];
  final bool _isSuccess = true;

@override
  void initState() {
    _getTransactions();
    super.initState();
  }
  void _getTransactions() async {
    final responseTransactions = await _dio.get(
      'https://ecocharge.azurewebsites.net/transaction/?skip=0&limit=10',
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization':
            'Bearer ${await _secureStorage.read(key: 'access_token')}',
      }),
    );
    List<dynamic> responseData = responseTransactions.data;
    setState(() {
      transactions = responseData.map((e) => Transaction.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Transactions'),
      ),
      body: RefreshIndicator(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSuccess ? Colors.green : Colors.red,
                          ),
                          child: const Icon(
                            Icons.wallet,
                            color: Colors.white,
                            size: 30.0,
                          ))),
                  title: Text('Transaction ${index + 1}'),
                  subtitle: Text(convertDate(
                      DateTime.parse(transactions[index].createdAt.toString()))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '+ ฿${transactions[index].amount.toString()}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        onRefresh: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
        },
      ),
    );
  }
  String convertDate(DateTime date) {
    return DateFormat('HH:mm d-MMM-yyyy').format(date);
  }
}
