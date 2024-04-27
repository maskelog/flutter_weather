import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'vworld_address.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VWorld Address Lookup',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('VWorld Address Lookup'),
        ),
        body: const AddressFinder(),
      ),
    );
  }
}
