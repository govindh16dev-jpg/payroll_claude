import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:payroll/util/custom_widgets.dart';

import '../../config/constants.dart';

class FreshdeskSupportScreen extends StatefulWidget {
  final String token;

  const FreshdeskSupportScreen({super.key, required this.token});

  @override
  State<FreshdeskSupportScreen> createState() => _FreshdeskSupportScreenState();
}

class _FreshdeskSupportScreenState extends State<FreshdeskSupportScreen> {
  late final WebViewController _webViewController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();

    final url = "${ApiConstants.supportUrl}/${widget.token}";
    log("Initial load URL: ${widget.token}");
    log("Initial load URL: $url");

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          "Mozilla/5.0 (Linux; Android 10; Mobile; rv:109.0) Gecko/115.0 Firefox/115.0"
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            log("Trying to navigate to: ${request.url}");
            return NavigationDecision.navigate;
          },
          onProgress: (int progress) {
            log("Loading progress: $progress%");
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            log("Page started loading: $url");
          },
          onPageFinished: (String url) {
            log("Page finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            log("Web resource error: ${error.description}, code: ${error.errorCode}");
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _progress < 1.0 ? Center(child: loadingIndicator()) : const SizedBox.shrink(),
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      ),
    );
  }
}
