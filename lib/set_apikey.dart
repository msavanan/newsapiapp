import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:newsapiapp/api_key.dart';
import 'package:newsapiapp/home_page.dart';

class SetApiKey extends StatefulWidget {
  const SetApiKey({Key? key, this.topPadding = 0.3}) : super(key: key);
  final double topPadding;

  @override
  State<SetApiKey> createState() => _SetApiKeyState();
}

class _SetApiKeyState extends State<SetApiKey> {
  final _formKey = GlobalKey<FormState>();
  bool isValidating = false;
  final ApiKey verifyApiKey = ApiKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: isValidating,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * widget.topPadding),
              child: Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text('API Key'))),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, right: 30, top: 5),
                          child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter(
                                    RegExp('[a-zA-Z0-9]'),
                                    allow: true)
                              ],
                              onChanged: (apiKey) {
                                verifyApiKey.key = apiKey.trim();
                              },
                              validator: (String? apiKey) {
                                if ((apiKey?.isEmpty)!) {
                                  return "API key can't be empty";
                                } else if (verifyApiKey.status == 'error' ||
                                    verifyApiKey.code == 'apiKeyInvalid') {
                                  return 'Invalid API Key';
                                } else if (verifyApiKey.code ==
                                    'apiKeyMissing') {
                                  return 'API Key is missing';
                                }
                              },
                              decoration: const InputDecoration(
                                  hintText: 'API Key goes here',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide())))),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                            child: const Text('Ok'),
                            onPressed: () async {
                              setState(() {
                                isValidating = true;
                              });
                              await verifyApiKey.getResponse();
                              setState(() {
                                isValidating = false;
                              });
                              if ((_formKey.currentState?.validate())!) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'apiKey', verifyApiKey.key);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const HomePage();
                                }));
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: InkWell(
                            onTap: () async {
                              try {
                                const url = 'https://newsapi.org/register';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                }
                              } catch (error) {
                                if (kDebugMode) {
                                  print(error);
                                }
                              }
                            },
                            child: const Text("Get ApiKey")),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
