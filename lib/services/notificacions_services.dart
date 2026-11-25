import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Aquesta funció ha d'estar fora de qualsevol classe
// per poder gestionar notificacions quan l'app està tancada
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Notificació rebuda en background: ${message.notification?.title}');
}

class NotificacionsService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicialitzar() async {
    // Demanem permís a l'usuari
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurem les notificacions locals (per quan l'app està oberta)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Creem el canal de notificacions per Android
    const channel = AndroidNotificationChannel(
      'suaopaga_channel',
      'SuaOPaga',
      description: 'Notificacions de SuaOPaga',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Quan arriba una notificació amb l'app oberta
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'suaopaga_channel',
            'SuaOPaga',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });

    // Guardem el token FCM a Firestore per poder enviar notificacions
    await _guardarToken();

    // Actualitzem el token si canvia
    messaging.onTokenRefresh.listen(_guardarTokenString);
  }

  static Future<void> _guardarToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _guardarTokenString(token);
  }

  static Future<void> _guardarTokenString(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}