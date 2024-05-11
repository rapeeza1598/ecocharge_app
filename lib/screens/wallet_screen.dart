import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../models/me.dart';
import '../models/transaction.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  double balance = 0.0;
  List<Transaction> transactions = [];

  @override
  void initState() {
    _getBalance();
    super.initState();
  }

  void _getBalance() async {
    final responseUser = await _dio.get(
      'https://ecocharge.azurewebsites.net/user/me',
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization':
            'Bearer ${await _secureStorage.read(key: 'access_token')}',
      }),
    );
    Me me = Me.fromJson(responseUser.data);
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
      balance = me.balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Wallet'),
        ),
        body: RefreshIndicator(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 400,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Balance",
                          style:
                              TextStyle(fontSize: 24.0, color: Colors.white)),
                      Text("฿${balance.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 48.0, color: Colors.white)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/topup');
                        },
                        child: const Text('Top-up'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/recent_transaction');
                        },
                        child: const Text("View All"))
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      transactions
                          .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                              child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: const Icon(
                                    Icons.wallet,
                                    color: Colors.white,
                                    size: 30.0,
                                  ))),
                          title: Text('Transaction ${index + 1}'),
                          subtitle:
                              Text(convertDate(transactions[index].createdAt)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                '+ ฿ ${transactions[index].amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
                              ),
                              // const Icon(
                              //   Icons.arrow_forward_ios,
                              //   color: Colors.grey,
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            _getBalance();
            setState(() {});
          },
        ));
  }

  String convertDate(DateTime date) {
    return DateFormat('HH:mm d-MMM-yyyy').format(date);
  }
}
