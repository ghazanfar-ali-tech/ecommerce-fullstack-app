import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class SafepayScreen extends StatelessWidget {
  const SafepayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safepay Payment")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Pay Now - PKR 500"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        onPressed: () async {
  // Save references before any async gap
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final payment = await PaymentService.createPayment(
      amount: 500,
      userId: 1,
    );

    navigator.pop();

    final tracker = payment["tracker"];
    final orderId = payment["order_id"];

    if (tracker == null || orderId == null) {
      throw Exception("Invalid backend response: $payment");
    }

    final result = await navigator.push(
      MaterialPageRoute(
        builder: (context) => SafepayWebViewScreen(
          tracker: tracker,
          orderId: orderId,
        ),
      ),
    );

    if (result == "paid") {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("✅ Payment Successful!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (result == "failed") {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Payment Failed"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Payment Cancelled"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (navigator.canPop()) {
      navigator.pop();
    }

    debugPrint("Error: $e");
    messenger.showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
},
        ),
      ),
    );
  }
}

class SafepayWebViewScreen extends StatefulWidget {
  final String tracker;
  final int orderId;

  const SafepayWebViewScreen({
    super.key,
    required this.tracker,
    required this.orderId,
  });

  @override
  State<SafepayWebViewScreen> createState() => _SafepayWebViewScreenState();
}

class _SafepayWebViewScreenState extends State<SafepayWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasVerified = false;

  @override
  void initState() {
    super.initState();

   final checkoutUrl = Uri.https(
  'sandbox.api.getsafepay.com',
  '/components',
  {
    'beacon': widget.tracker,
    'order_id': widget.orderId.toString(),
    'source': 'mobile',
    'env': 'sandbox',
    'user': 'user_d75110e4-f52e-464d-96bd-490f75e7fc71',  
  },
).toString();

    print("Loading Safepay checkout URL: $checkoutUrl");

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("Page started: $url");
            setState(() {
              isLoading = true;
            });
            _checkUrl(url);
          },
          onPageFinished: (url) {
            print("Page finished: $url");
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            print("Navigation request: ${request.url}");
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            print("Web resource error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(checkoutUrl));
  }

  void _checkUrl(String url) async {
    if (hasVerified) return;

    print("Checking URL: $url");

   
    if (url.contains("/mobile")) {
      print("Detected /mobile redirect: $url");
      
      final uri = Uri.parse(url);
      final action = uri.queryParameters['action'];
      
      print("Action: $action");

      hasVerified = true;

      if (action == "complete" || action == "completed") {
      
        await _verifyAndClose("paid");
      } else if (action == "cancelled" || action == "cancel") {
  
        if (mounted) {
          Navigator.pop(context, "cancelled");
        }
      } else {
    
        await _verifyAndClose("failed");
      }
    }

    else if (url.contains("/error")) {
      print("Error page detected: $url");
      hasVerified = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment setup error. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, "failed");
      }
    }
  }

  Future<void> _verifyAndClose(String defaultStatus) async {
    try {
      print("Verifying payment with backend...");
      final status = await PaymentService.verifyPayment(
        tracker: widget.tracker,
        orderId: widget.orderId,
      );
      
      print("Verification result: $status");
      
      if (mounted) {
        Navigator.pop(context, status);
      }
    } catch (e) {
      print("Verification error: $e");
      if (mounted) {
        Navigator.pop(context, defaultStatus);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!hasVerified) {
              Navigator.pop(context, "cancelled");
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading Safepay checkout..."),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PaymentService {
  static const String baseUrl = "http://192.168.10.4:8000/api";

  static Future<Map<String, dynamic>> createPayment({
    required int amount,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create-payment/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "user_id": userId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error response: ${response.body}");
      throw Exception("Payment creation failed: ${response.statusCode}");
    }
  }

  static Future<String> verifyPayment({
    required String tracker,
    required int orderId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-payment/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tracker": tracker,
        "order_id": orderId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["status"];
    } else {
      print("Verification error: ${response.body}");
      throw Exception("Payment verification failed");
    }
  }
}
