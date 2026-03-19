import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] ${message.notification?.title}');
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    await _initLocalNotifications();
    await saveTokenToFirestore();

 _auth.authStateChanges().listen((user) async {
    if (user != null) {
      await saveTokenToFirestore();
    }
  });
  
    _fcm.onTokenRefresh.listen((_) => saveTokenToFirestore());
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }



Future<void> showOrderNotification({
  required String title,
  required String body,
}) async {
  await _localNotif.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'order_updates',
        'Order Updates',
        importance: Importance.max,
        priority: Priority.high,
        color: const Color(0xFFE91E8C),
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}
  Future<void> saveTokenToFirestore() async {
    final uid = _auth.currentUser?.uid;
   if (uid == null) {
    debugPrint('[FCM] No user logged in - cannot save token');
    return;
  }

    final token = await _fcm.getToken();
    if (token == null) {
    debugPrint('[FCM] FCM token is null');
    return;
  }

    await _db.collection('users').doc(uid).set(
      {'fcmToken': token, 'tokenUpdatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
debugPrint('[FCM]  Token saved for uid: $uid');
  debugPrint('[FCM]  Token: $token');  }

  Future<void> deleteToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update(
        {'fcmToken': FieldValue.delete()},
      );
    }
    await _fcm.deleteToken();
  }

  Future<void> sendOrderPlacedNotification({
    required String orderId,
    required int totalAmount,
    required int itemCount,
  }) async {
    debugPrint('[FCM] sendOrderPlacedNotification called'); 
    final uid = _auth.currentUser?.uid;
      if (uid == null) {
    debugPrint('[FCM] uid is null');                        
    return;
  }
    final userDoc = await _db.collection('users').doc(uid).get();
    final token = userDoc.data() != null ? userDoc.data()!['fcmToken'] : null;
     debugPrint('[FCM] token from Firestore: $token');           

  if (token == null) {
    debugPrint('[FCM] token is null in Firestore');          
    return;
  }

    await _sendFCMNotification(
      token: token,
      title: '🛍️ Order Placed Successfully!',
      body:
          'Your order $orderId ($itemCount item${itemCount > 1 ? 's' : ''}) worth \$$totalAmount is confirmed.',
      data: {
        'orderId': orderId,
        'screen': 'orders',
        'status': 'active',
      },
    );
  }

  Future<void> sendOrderStatusNotification({
    required String orderId,
    required String status,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _db.collection('users').doc(uid).get();
    final token = userDoc.data() != null ? userDoc.data()!['fcmToken'] : null;
    if (token == null) return;

    final Map<String, Map<String, String>> statusMessages = {
      'shipped': {
        'title': '📦 Order Shipped!',
        'body': 'Your order $orderId is on its way.',
      },
      'delivered': {
        'title': '✅ Order Delivered!',
        'body': 'Your order $orderId has been delivered.',
      },
      'completed': {
        'title': '🎉 Order Completed!',
        'body': 'Thanks for shopping! Order $orderId is complete.',
      },
      'cancelled': {
        'title': '❌ Order Cancelled',
        'body': 'Your order $orderId has been cancelled.',
      },
    };

    final notif = statusMessages[status];
    if (notif == null) return;

    await _sendFCMNotification(
      token: token,
      title: notif['title']!,
      body: notif['body']!,
      data: {
        'orderId': orderId,
        'screen': 'orders',
        'status': status,
      },
    );
  }

 Future<void> _sendFCMNotification({
  required String token,
  required String title,
  required String body,
  required Map<String, String> data,
}) async {
  try {
final jsonString = await rootBundle.loadString('assets/service_account.json');
final jsonMap = json.decode(jsonString);

final serviceAccount = ServiceAccountCredentials.fromJson(jsonMap);

final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
final client = await clientViaServiceAccount(serviceAccount, scopes);

final projectId = jsonMap['project_id'];

   final message = {
  'message': {
    'token': token,
    'notification': {'title': title, 'body': body},
    'data': data,
    'android': {
      'priority': 'HIGH',              
      'notification': {
        'channel_id': 'order_updates',
        'color': '#E91E8C',
       
      },
    },
    'apns': {
      'payload': {
        'aps': {'sound': 'default', 'badge': 1},
      },
    },
  },
};

    final response = await client.post(
      Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(message),
    );

    client.close();

      if (response.statusCode == 200) {
      debugPrint('[FCM]  Notification sent: $title');
    } else {
      debugPrint('[FCM]  Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) { 
    debugPrint('[FCM]  Exception: $e');
  }
}

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    const channel = AndroidNotificationChannel(
      'order_updates',
      'Order Updates',
      description: 'Notifications about your order status',
      importance: Importance.high,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

 void _handleForeground(RemoteMessage message) {
  debugPrint('[FCM] Foreground received: ${message.data}');

  final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
  final body  = message.notification?.body  ?? message.data['body']  ?? '';

  _localNotif.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'order_updates',
        'Order Updates',
        importance: Importance.max,      
        priority: Priority.high,
        color: const Color(0xFFE91E8C),
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

  void _handleTap(RemoteMessage message) {
    final screen = message.data['screen'];
    debugPrint('[FCM] Tapped → screen: $screen');
   
  }
}