import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/theme.dart';

class MidtransWebViewScreen extends StatefulWidget {
  final String url;
  final String orderId;

  const MidtransWebViewScreen({
    super.key,
    required this.url,
    required this.orderId,
  });

  @override
  State<MidtransWebViewScreen> createState() => _MidtransWebViewScreenState();
}

class _MidtransWebViewScreenState extends State<MidtransWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Prevent going out of sandbox/payment if not needed, or let redirects happen
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pembayaran RUMA',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.olive,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // User closed the payment webview. Go back and show status check dialog
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.olive,
              ),
            ),
        ],
      ),
    );
  }
}
