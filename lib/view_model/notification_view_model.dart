import 'package:ecommerceapp/services/notification_services.dart/notification_services.dart';
import 'package:flutter/material.dart';


class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  Future<void> showNotification(String title, String body) async {
    _notificationService.show(
      title: title,
      body: body,
    );
  }


}
