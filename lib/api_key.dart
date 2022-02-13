import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiKey {
  String key = '';
  String q = '';
  String code = '';
  String status = '';
  bool isKeyExist = false;
  String query = '';

  static final ApiKey _verifyApiKey = ApiKey._instance();

  factory ApiKey() {
    return _verifyApiKey;
  }

  ApiKey._instance();

  exist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isApiKeyExist', prefs.containsKey('apiKey'));
    query = prefs.getString('query') ?? '';
    await prefs.setString('query', query);
    isKeyExist = prefs.getBool('isApiKeyExist')!;
    return isKeyExist;
  }

  setQuery(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('query', query);
  }

  getApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    key = (prefs.getString('apiKey'))!;
  }

  Future<void> getResponse() async {
    //final String url = "https://newsapi.org/v2/everything?q=bitcoin&apiKey=$apiKey";
    try {
      var response = await http.get(Uri(
        scheme: 'https',
        host: "newsapi.org",
        path: "v2/everything",
        query: 'q=bitcoin&apiKey=$key',
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
