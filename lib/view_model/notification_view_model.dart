import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/services/notification_services.dart/push_notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerceapp/services/notification_services.dart/notification_services.dart';

class NotificationViewModel extends ChangeNotifier {
  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> init() async {

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    if (!granted) {
      _isEnabled = false;
      notifyListeners();
      return;
    }
    final savedValue = await _loadFromFirestore();

    _isEnabled = savedValue;
    await _applySubscription(_isEnabled);
    notifyListeners();
  }

  Future<void> togglePush(bool value) async {
    _isEnabled = value;
    notifyListeners();

    await _applySubscription(value);
    await _saveToFirestore(value);      
    await _saveToPrefs(value);           
  }

  Future<void> _applySubscription(bool value) async {
    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic('new_products');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('new_products');
    }
  }

  Future<void> _saveToFirestore(bool value) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .set({'pushNotificationsEnabled': value}, SetOptions(merge: true));
  }

  Future<bool> _loadFromFirestore() async {
    if (_uid == null) return true; 
    try {
      final doc =
          await _firestore.collection('users').doc(_uid).get();
      if (doc.exists && doc.data()!.containsKey('pushNotificationsEnabled')) {
        return doc.data()!['pushNotificationsEnabled'] as bool;
      }
    } catch (_) {}
    return true; 
  }

  Future<void> _saveToPrefs(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notif_${_uid}', value);
  }



  Future<void> showNotification(String title, String body) async {
    if (!_isEnabled) return; 
    _notificationService.show(title: title, body: body);
  }

Future<void> showOrderNotification({
  required String title,
  required String body,
}) async {
  if (!_isEnabled) return; 
  await PushNotificationService.instance.showOrderNotification(
    title: title,
    body: body,
  );
}
  
}