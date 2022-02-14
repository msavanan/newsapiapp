import 'package:flutter/material.dart';

import 'package:newsapiapp/api_key.dart';
import 'package:newsapiapp/home_page.dart';
import 'package:newsapiapp/set_apikey.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiKey().exist();
  if (ApiKey().isKeyExist) {
    await ApiKey().getApiKey();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News API',
        home: ApiKey().isKeyExist ? const HomePage() : const SetApiKey());
  }
}
