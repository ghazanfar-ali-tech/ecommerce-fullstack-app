import 'package:ecommerceapp/view_model/app_version_info.dart';
import 'package:ecommerceapp/view_model/notification_view_model.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/privacy_and_policy_screen.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/terms_of_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false, // Replace with actual dark mode state
            onChanged: (value) {
              // Implement toggle dark mode functionality
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
  title: const Text('Push Notifications'),
  value: context.watch<NotificationViewModel>().isEnabled,
  onChanged: (value) {
    context.read<NotificationViewModel>().togglePush(value);
  },
),

          SwitchListTile(
            title: const Text('Email Notifications'),
            value: false,
            onChanged: (value) {
              // Implement email notification toggle
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Privacy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
                        Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PrivacyPolicyScreen(),
    ),
  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
                          Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const TermsOfServiceScreen(),
    ),
  );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Consumer<AppVersionInfoViewModel>(
              builder: (context, appVersionModel, child){
                return Text('${appVersionModel.packageInfo.version}+${appVersionModel.packageInfo.buildNumber}');
              }
              )
           
          ),
        ],
      ),
    );
  }
}
