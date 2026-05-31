import 'package:ecommerceapp/core/constants.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class SafepayScreen extends StatelessWidget {
  const SafepayScreen({super.key, required this.cartItems});

  final List<CartModel> cartItems;

  int get subtotal {
    int sub = 0;
    for (var item in cartItems) {
      sub += item.productPrice * item.quantity;
    }
    return (sub * 280);
  }

  int get shipping => 15;
  int get tax => 24;
  int get total => subtotal + shipping + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Checkout",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order summary",
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: "Subtotal",
                          value: "Rs $subtotal",
                          context: context,
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: "Shipping",
                          value: "Rs $shipping",
                          context: context,
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: "Tax",
                          value: "Rs $tax",
                          context: context,
                        ),
                        const SizedBox(height: 16),
                        Divider(color: AppColors.divider(context), height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors
                                  .primaryGradient
                                  .createShader(bounds),
                              child: Text(
                                "Rs $total",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Safepay",
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Secure payment gateway",
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Secured",
                            style: TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Your payment info is encrypted and secure.",
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                border: Border(
                  top: BorderSide(color: AppColors.border(context)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.accentShadow,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        final payment = await PaymentService.createPayment(
                          amount: total,
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
                            _buildSnackBar(
                              "Payment Successful!",
                              AppColors.success,
                            ),
                          );
                        } else if (result == "failed") {
                          messenger.showSnackBar(
                            _buildSnackBar("Payment Failed", AppColors.error),
                          );
                        } else {
                          messenger.showSnackBar(
                            _buildSnackBar(
                              "Payment Cancelled",
                              AppColors.warning,
                            ),
                          );
                        }
                      } catch (e) {
                        if (navigator.canPop()) navigator.pop();
                        debugPrint("Error: $e");
                        messenger.showSnackBar(
                          _buildSnackBar("Error: $e", AppColors.error),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Pay Rs $total",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

SnackBar _buildSnackBar(String message, Color color) {
  return SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 3),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

    final checkoutUrl =
        Uri.https('sandbox.api.getsafepay.com', '/checkout/pay', {
          'beacon': widget.tracker,
          'order_id': widget.orderId.toString(),
          'source': 'mobile',
          'env': 'sandbox',
        }).toString();

    debugPrint("Loading Safepay checkout URL: $checkoutUrl");

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint("Page started: $url");
            setState(() => isLoading = true);
            _checkUrl(url);
          },
          onPageFinished: (url) {
            debugPrint("Page finished: $url");
            setState(() => isLoading = false);
            _checkUrl(url);
          },
          onNavigationRequest: (request) {
            debugPrint("Navigation request: ${request.url}");
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint("Web resource error: ${error.description}");
          },
        ),
      )
      ..loadRequest(
        Uri.parse(checkoutUrl),
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      );
  }

  void _checkUrl(String url) async {
    if (hasVerified) return;
    debugPrint("Checking URL: $url");

    if (url.contains('/mobile')) {
      debugPrint("Detected /mobile redirect: $url");
      final uri = Uri.parse(url);
      final action = uri.queryParameters['action'];
      debugPrint("Action param: $action");
      hasVerified = true;
      if (action == 'complete' || action == 'completed') {
        await _verifyAndClose("paid");
      } else if (action == 'cancelled' || action == 'cancel') {
        if (mounted) Navigator.pop(context, "cancelled");
      } else {
        await _verifyAndClose("failed");
      }
      return;
    }

    if (url.contains('/success') || url.contains('status=success')) {
      hasVerified = true;
      await _verifyAndClose("paid");
      return;
    }

    if (url.contains('/cancel') || url.contains('status=cancel')) {
      hasVerified = true;
      if (mounted) Navigator.pop(context, "cancelled");
      return;
    }

    if (url.contains('/error') || url.contains('status=error')) {
      debugPrint("Error page detected: $url");
      hasVerified = true;
      if (mounted) Navigator.pop(context, "failed");
    }
  }

  Future<void> _verifyAndClose(String defaultStatus) async {
    try {
      debugPrint("Verifying payment with backend...");
      final status = await PaymentService.verifyPayment(
        tracker: widget.tracker,
        orderId: widget.orderId,
      );
      debugPrint("Verification result: $status");
      if (mounted) Navigator.pop(context, status);
    } catch (e) {
      debugPrint("Verification error: $e");
      if (mounted) Navigator.pop(context, defaultStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Complete payment",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () {
            if (!hasVerified) Navigator.pop(context, "cancelled");
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      "Loading Safepay checkout...",
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
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
  static const String baseUrl = AppConstants.safePayUrl;

  static Future<Map<String, dynamic>> createPayment({
    required int amount,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create-payment/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"amount": amount, "user_id": userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint("Error response: ${response.body}");
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
      body: jsonEncode({"tracker": tracker, "order_id": orderId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["status"];
    } else {
      debugPrint("Verification error: ${response.body}");
      throw Exception("Payment verification failed");
    }
  }
}
