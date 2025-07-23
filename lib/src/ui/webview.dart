import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart' as view;

String? response = "null";

Future<String?> value() async {
  return response;
}

// Mobile-optimized WebView for popup usage
class WebView extends StatefulWidget {
  final String url;
  final double? height;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const WebView({
    required this.url,
    this.height,
    this.showCloseButton = true,
    this.onClose,
    Key? key,
  }) : super(key: key);

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
      ..setBackgroundColor(Colors.white)
      // Updated user agent for better mobile compatibility
      ..setUserAgent('Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
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
            controller.runJavaScriptReturningResult("document.getElementById('return')?.innerText").then((value) async {
              if (value != null && value.toString().isNotEmpty && value.toString() != 'null' && value.toString() != '"null"' && value.toString().length > 7) {
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
    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // WebView
            view.WebViewWidget(controller: controller),

            // Close button (floating)
            if (widget.showCloseButton)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: widget.onClose ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

            // Loading indicator
            if (isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      if (loadingProgress > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${(loadingProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: LinearProgressIndicator(
                    value: loadingProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Alternative WebView widget for use inside other widgets
class WebViewWidget extends StatefulWidget {
  final String url;
  final double? height;
  final bool showLoader;
  final EdgeInsets? padding;

  const WebViewWidget({
    required this.url,
    this.height,
    this.showLoader = true,
    this.padding,
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
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
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

            controller.runJavaScriptReturningResult("document.getElementById('return')?.innerText").then((value) async {

              if (value != null && value.toString().isNotEmpty && value.toString() != 'null' && value.toString() != '"null"' && value.toString()!.length > 7) {
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
    return Container(
      padding: widget.padding,
      height: widget.height ?? MediaQuery.of(context).size.height * 0.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            view.WebViewWidget(controller: controller),
            if (widget.showLoader && isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Mobile-optimized full-screen WebView
class MobileWebView extends StatefulWidget {
  final String url;
  final String? title;

  const MobileWebView({
    required this.url,
    this.title,
    Key? key,
  }) : super(key: key);

  @override
  State<MobileWebView> createState() => _MobileWebViewState();
}

class _MobileWebViewState extends State<MobileWebView> {
  late view.WebViewController controller;
  bool isLoading = true;
  double loadingProgress = 0.0;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = view.WebViewController()
      ..setJavaScriptMode(view.JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
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
            _updateNavigationButtons();
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            _updateNavigationButtons();

            controller.runJavaScriptReturningResult("document.getElementById('return')?.innerText").then((value) async {
              if (value != null && value.toString().isNotEmpty && value.toString() != 'null' && value.toString() != '"null"' && value.toString()!.length > 7) {
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
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _updateNavigationButtons() async {
    final back = await controller.canGoBack();
    final forward = await controller.canGoForward();
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title ?? 'Web View',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: canGoBack ? Colors.black : Colors.grey,
            ),
            onPressed: canGoBack ? () => controller.goBack() : null,
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: canGoForward ? Colors.black : Colors.grey,
            ),
            onPressed: canGoForward ? () => controller.goForward() : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => controller.reload(),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            view.WebViewWidget(controller: controller),
            if (isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(loadingProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isLoading && loadingProgress > 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: Colors.grey[200],
                  child: LinearProgressIndicator(
                    value: loadingProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
