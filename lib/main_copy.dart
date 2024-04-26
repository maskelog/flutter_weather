import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '날씨'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();
  List<dynamic> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Map<String, String> params = {
                    'confmKey': dotenv.env['confmKey']!,
                    'currentPage': '1',
                    'countPerPage': '10',
                    'keyword': controller.text,
                    'resultType': 'json',
                  };
                  http.post(
                      Uri.parse(
                          'https://business.juso.go.kr/addrlink/addrLinkApiJsonp.do'),
                      body: params,
                      headers: {
                        'content-type': 'application/x-www-form-urlencoded',
                      }).then((response) {
                    String responseBody = response.body;
                    int startIndex = responseBody.indexOf('(') + 1;
                    int endIndex = responseBody.lastIndexOf(')');
                    String jsonPart =
                        responseBody.substring(startIndex, endIndex);
                    dev.log('JSON part: $jsonPart');
                    var jsonResponse = jsonDecode(jsonPart);
                    if (jsonResponse.containsKey('results') &&
                        jsonResponse['results'].containsKey('juso')) {
                      setState(() {
                        list = jsonResponse['results']['juso'];
                      });
                    } else {
                      dev.log('No valid data in response');
                      setState(() {
                        list = [];
                      });
                    }
                  }).catchError((error) {
                    dev.log('Error fetching data: $error');
                    setState(() {
                      list = [];
                    });
                  });
                },
                child: const Text('검색'),
              ),
            ],
          ),
          Expanded(
              child: (ListView.separated(
                  itemBuilder: (context, index) {
                    return Text(
                        '${list[index]['siNm']} ${list[index]['sggNm']} ${list[index]['zipNo']} ${list[index]['roadAddr']}');
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: list.length)))
        ],
      ),
    );
  }
}
