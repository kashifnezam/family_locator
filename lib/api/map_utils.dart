import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> searchPlace(String query) async {
  String encodedQuery = Uri.encodeQueryComponent(query);
  debugPrint(encodedQuery);
  var data = [];
  String url =
      'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json';

  try {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      return data;
    } else {
      debugPrint('Error: ${response.reasonPhrase}');
      return data;
    }
  } catch (e) {
    debugPrint('Error: $e');
    return data;
  }
}
