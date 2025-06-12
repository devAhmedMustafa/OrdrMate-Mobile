import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebView({super.key, required this.paymentUrl});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
            onNavigationRequest: (request) {
              final uri = Uri.parse(request.url);

              if (uri.host == 'accept.paymobsolutions.com' &&
                  uri.path == '/api/acceptance/post_pay') {
                final success = uri.queryParameters['success'];

                if (success == 'false') {
                  Navigator.of(context).pop(false); // Payment failed or cancelled
                } else {
                  Navigator.of(context).pop(true); // Payment succeeded
                }

                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            }
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
