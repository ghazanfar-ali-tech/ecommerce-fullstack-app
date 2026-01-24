import 'package:flutter/material.dart';
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Privacy Policy\n\n'
          'This application is an e-commerce demo project developed for learning and portfolio purposes.\n\n'

          'Data Collection\n'
          'The app may collect basic user information such as name, email address, and order details to demonstrate core e-commerce functionality.\n\n'

          'Backend & Third-Party Services\n'
          'This app uses Firebase services and a backend powered by Django REST API. '
          'Data is processed only to support application features such as authentication, product management, and order handling.\n\n'

          'Data Usage\n'
          'Collected data is used solely for app functionality and is not sold or shared with third parties for marketing purposes.\n\n'

          'Data Security\n'
          'Reasonable measures are taken to protect user data; however, this app is not intended for production use.\n\n'

          'Contact\n'
          'For any questions regarding this privacy policy, please contact the developer.',
        ),
      ),
    );
  }
}
