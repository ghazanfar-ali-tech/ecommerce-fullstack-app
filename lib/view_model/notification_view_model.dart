import 'package:ecommerceapp/services/notification_services.dart/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class NotificationViewModel extends ChangeNotifier {

 bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  final NotificationService _notificationService = NotificationService();

  Future<void> showNotification(String title, String body) async {
    _notificationService.show(
      title: title,
      body: body,
    );
  }

  Future<void> init() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _isEnabled =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    if (_isEnabled) {
      await FirebaseMessaging.instance.subscribeToTopic('new_products');
    }

    notifyListeners();
  }

  Future<void> togglePush(bool value) async {
    _isEnabled = value;

    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic('new_products');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('new_products');
    }

    notifyListeners();
  }

}
