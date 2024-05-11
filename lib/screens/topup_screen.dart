import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'promptpay_screen.dart';
// Import services for input formatters

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'Enter the amount you want to top up:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                labelText: 'Amount',
                floatingLabelAlignment: FloatingLabelAlignment.center,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    amountController.text = '100';
                  },
                  child: const Text('100'),
                ),
                ElevatedButton(
                  onPressed: () {
                    amountController.text = '200';
                  },
                  child: const Text('200'),
                ),
                ElevatedButton(
                  onPressed: () {
                    amountController.text = '300';
                  },
                  child: const Text('300'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    amountController.text = '400';
                  },
                  child: const Text('400'),
                ),
                ElevatedButton(
                  onPressed: () {
                    amountController.text = '500';
                  },
                  child: const Text('500'),
                ),
                ElevatedButton(
                  onPressed: () {
                    amountController.text = '600';
                  },
                  child: const Text('600'),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){
                      int amount = int.parse(amountController.text);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PromptPayScreen(amount)));
                    },
                    child: const Text('Top Up'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _topUpSave() {
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
                        child:
                            Icon(Icons.wallet, size: 50, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Press Confirm to top up wallet',
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
                      int amount = int.parse(amountController.text);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PromptPayScreen(amount)));
                    },
                    child: const Text('Confirm')),
              ],
            ));
  }
}
