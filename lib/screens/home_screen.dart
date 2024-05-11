import 'package:flutter/material.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: null,
      // ),
      // news feed list
      body: Padding(padding: const EdgeInsets.all(10),
      child: Card(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              title: const Text('News Title'),
              subtitle: const Text('News Description'),
              leading: const Icon(Icons.article),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // navigate to news detail screen
              },
            );
          },
        ),
      ),),
    );
  }
}
