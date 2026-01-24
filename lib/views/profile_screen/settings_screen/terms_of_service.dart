import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Terms of Service\n\n'
          'This application is an e-commerce demo project created for learning and portfolio purposes.\n\n'

          'Use of the App\n'
          'Users may browse products, place test orders, and interact with the app solely for demonstration purposes.\n\n'

          'User Accounts\n'
          'Users are responsible for maintaining the confidentiality of their account information.\n\n'

          'Admin Panel\n'
          'Product data and order management are controlled via an admin panel and may change without notice.\n\n'

          'Limitations\n'
          'This app does not process real payments and does not guarantee product availability, accuracy, or delivery.\n\n'

          'Liability\n'
          'The developer is not responsible for any losses or damages arising from the use of this demo application.\n\n'

          'Termination\n'
          'Accounts may be suspended or removed if misuse of the app is detected.',
        ),
      ),
    );
  }
}
