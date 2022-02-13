import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends StatefulWidget {
  final String postUrl;

  const ArticleView({Key? key, required this.postUrl}) : super(key: key);

  @override
  _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  ValueNotifier<bool> status = ValueNotifier<bool>(true);
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  onProgress(int val) {
    if (val == 100) {
      if (status.value != false) {
        status.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: status,
        builder: (BuildContext context, bool isLoading, child) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: WebView(
                      initialUrl: widget.postUrl,
                      onProgress: (val) {
                        onProgress(val);
                      },
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Container())
                ],
              ),
            ),
          );
        });
  }
}
