import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VerifyApiKey {
  String apiKey = '';
  String q = '';
  String code = '';
  String status = '';

  Future<void> getResponse() async {
    //final String url = "https://newsapi.org/v2/everything?q=bitcoin&apiKey=$apiKey";
    try {
      var response = await http.get(Uri(
        scheme: 'https',
        host: "newsapi.org",
        path: "v2/everything",
        query: 'q=bitcoin&apiKey=$apiKey',
      ));
      var body = jsonDecode(response.body);
      status = body['status'];
      code = body['code'];
      if (kDebugMode) {
        print(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
