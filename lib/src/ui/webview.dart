import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as view;

String? response = "null";

Future<String?> value() async {
  return response;
}

class WebView extends StatefulWidget {
  final String url;

  const WebView({required this.url, Key? key}) : super(key: key);

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late view.WebViewController controller;
  bool isLoading = true;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = view.WebViewController()
      ..setJavaScriptMode(view.JavaScriptMode.unrestricted)
    // Set white background instead of transparent black
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36'
      )
      ..setNavigationDelegate(
        view.NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });

            // Execute JavaScript to get response
            controller.runJavaScriptReturningResult(
                "document.getElementById('return')?.innerText || 'null'")
                .then((value) async {
              if (value.toString().isNotEmpty && value.toString() != 'null') {
                response = value.toString();
              }
            }).catchError((error) {
              print('JavaScript execution error: $error');
            });
          },
          onWebResourceError: (view.WebResourceError error) {
            print('WebView error: ${error.description}');
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (view.NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return view.NavigationDecision.prevent;
            }
            return view.NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // WebView
          view.WebViewWidget(controller: controller),

          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Progress bar at the top
          if (isLoading && loadingProgress > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                color: Colors.grey[300],
                child: LinearProgressIndicator(
                  value: loadingProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Alternative WebView widget for use inside other widgets
class WebViewWidget extends StatefulWidget {
  final String url;
  final double? height;
  final bool showLoader;

  const WebViewWidget({
    required this.url,
    this.height,
    this.showLoader = true,
    Key? key,
  }) : super(key: key);

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  late view.WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = view.WebViewController()
      ..setJavaScriptMode(view.JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36'
      )
      ..setNavigationDelegate(
        view.NavigationDelegate(
          onPageStarted: (String url) {
            if (widget.showLoader) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (widget.showLoader) {
              setState(() {
                isLoading = false;
              });
            }

            controller.runJavaScriptReturningResult(
                "document.getElementById('return')?.innerText || 'null'")
                .then((value) async {
              if (value.toString().isNotEmpty && value.toString() != 'null') {
                response = value.toString();
              }
            }).catchError((error) {
              print('JavaScript execution error: $error');
            });
          },
          onWebResourceError: (view.WebResourceError error) {
            print('WebView error: ${error.description}');
            if (widget.showLoader) {
              setState(() {
                isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          view.WebViewWidget(controller: controller),
          if (widget.showLoader && isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}