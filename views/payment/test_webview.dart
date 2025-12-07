import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestWebViewSimple extends StatefulWidget {
  const TestWebViewSimple({Key? key}) : super(key: key);

  @override
  State<TestWebViewSimple> createState() => _TestWebViewSimpleState();
}

class _TestWebViewSimpleState extends State<TestWebViewSimple> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test WebView')),
      body: WebViewWidget(controller: controller),
    );
  }
}