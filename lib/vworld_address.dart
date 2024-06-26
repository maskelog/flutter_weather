// vworld_address.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressFinder extends StatefulWidget {
  const AddressFinder({Key? key}) : super(key: key);

  @override
  State<AddressFinder> createState() => _AddressFinderState();
}

class _AddressFinderState extends State<AddressFinder> {
  String _address = 'Press button to get your address';

  @override
  void initState() {
    super.initState();
    getPositionAndAddress();
  }

  Future<void> getPositionAndAddress() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition();
      getAddressFromCoordinates(position);
    } catch (e) {
      setState(() {
        _address = 'Failed to get location: $e';
      });
    }
  }

  Future<void> getAddressFromCoordinates(Position position) async {
    String apiKey = dotenv.env['VWORLDKEY']!;
    Map<String, String> params = {
      'key': apiKey,
      'service': 'address',
      'version': '2.0',
      'request': 'getAddress',
      'format': 'json',
      'point': '${position.longitude},${position.latitude}',
      'crs': 'epsg:4326',
      'type': 'both',
      'zipcode': 'true',
      'simple': 'false'
    };

    String baseUrl = "https://api.vworld.kr/req/address";
    String queryString = Uri(queryParameters: params).query;
    String requestUrl = '$baseUrl?$queryString';

    http.Response response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var responseResult = jsonResponse['response']['result'];
      if (responseResult != null && responseResult.isNotEmpty) {
        var addressText = responseResult[0]['text'];
        setState(() {
          _address = addressText ?? 'No address found';
        });
      } else {
        print('Response result is empty or null: $jsonResponse');
        setState(() {
          _address = 'No address found';
        });
      }
    } else {
      print('Failed to fetch address. Status code: ${response.statusCode}');
      setState(() {
        _address = 'Failed to fetch address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_address, textAlign: TextAlign.center),
          ),
          ElevatedButton(
            onPressed: getPositionAndAddress,
            child: const Text('Get Address'),
          ),
        ],
      ),
    );
  }
}
