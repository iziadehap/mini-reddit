import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mini_reddit_v2/core/services/storage_service.dart';
import 'package:mini_reddit_v2/core/utils/supabase_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // ============================================
  // 1. تسجيل الجهاز في قاعدة البيانات
  // ============================================
  Future<Map<String, dynamic>> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User is not authenticated');
    }

    final res = await _supabase.rpc(
      'register_device',
      params: {
        'p_user_id': user.id,
        'p_fcm_token': fcmToken,
        'p_platform': platform,
      },
    );

    return res;
  }

  // ============================================
  // 2. إلغاء تسجيل الجهاز (عند تسجيل الخروج)
  // ============================================
  Future<void> unregisterDevice({required String fcmToken}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.rpc(
      'unregister_device',
      params: {'p_user_id': user.id, 'p_fcm_token': fcmToken},
    );
  }

  // ============================================
  // 3. جلب أجهزة المستخدم (موجودة بالفعل ولكن نحتاج تصحيحها)
  // ============================================
  Future<List<Map<String, dynamic>>> getUserDevices() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return [];
    }

    final res = await _supabase.rpc(
      'get_user_devices',
      params: {'p_user_id': user.id},
    );

    return List<Map<String, dynamic>>.from(res ?? []);
  }

  // ============================================
  // 4. حذف جهاز معين
  // ============================================
  Future<void> deleteUserDevice({required String deviceId}) async {
    await _supabase
        .from('user_devices')
        .delete()
        .eq('id', deviceId)
        .eq('user_id', _supabase.auth.currentUser!.id);
  }

  // ============================================
  // 5. طلب إذن الإشعارات والحصول على FCM Token
  // ============================================
  Future<String?> requestNotificationPermission() async {
    try {
      // طلب إذن الإشعارات
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('User declined notification permission');
        return null;
      }

      // الحصول على FCM Token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // ============================================
  // 6. إعداد استقبال الإشعارات
  // ============================================
  Future<void> setupPushNotifications() async {
    // 1. طلب الإذن والحصول على التوكن
    String? token = await requestNotificationPermission();

    if (token != null && _supabase.auth.currentUser != null) {
      // 2. تسجيل الجهاز في قاعدة البيانات
      await registerDevice(
        fcmToken: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
      );
    }

    // 3. الاستماع للإشعارات عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // هنا تقدر تعرض إشعار محلي باستخدام flutter_local_notifications
      // أو تحديث واجهة المستخدم
    });

    // 4. الاستماع للإشعارات عندما يكون التطبيق في الخلفية أو مقفول
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. التعامل مع الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped on notification!');
      // هنا تقدر تفتح الشاشة المناسبة بناءً على data
      _handleNotificationTap(message.data);
    });

    // 6. التعامل مع الإشعار الذي فتح التطبيق
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }

  // ============================================
  // 7. معالجة الضغط على الإشعار
  // ============================================
  void _handleNotificationTap(Map<String, dynamic> data) {
    // هنا تقرر الشاشة اللي هتفتحها بناءً على نوع الإشعار
    String? type = data['type'];
    String? postId = data['post_id'];
    String? commentId = data['comment_id'];

    print('Notification tapped: type=$type, postId=$postId');

    // مثال: لو كان الإشعار عن بوست، تفتح شاشة البوست
    // if (type == 'upvote' || type == 'downvote' || type == 'comment') {
    //   // navigationService.navigateToPostDetail(postId!);
    // }
  }

  // ============================================
  // 8. تحديث FCM Token (عند تغيير الجهاز أو التطبيق)
  // ============================================
  Future<void> refreshFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null && _supabase.auth.currentUser != null) {
      await registerDevice(
        fcmToken: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
      );
    }
  }

  // ============================================
  // 9. تعديل دالة signOut لإلغاء تسجيل الجهاز
  // ============================================
  Future<void> signOut() async {
    // إلغاء تسجيل الجهاز الحالي
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await unregisterDevice(fcmToken: token);
    }

    // تسجيل الخروج من Supabase
    await _supabase.auth.signOut();
  }

  // ============================================
  // الدوال الموجودة بالفعل (بدون تعديل)
  // ============================================

  Future<String> uploadProfileImage(File image) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User is not authenticated');
    }

    final fileExtension = image.path.split('.').last;
    final path = '${user.id}/profile.$fileExtension';

    return StorageService().uploadImage(
      file: image,
      bucket: SupabaseText.userProfileBuckets,
      path: path,
    );
  }

  Future<void> resendOtp(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);

    // بعد تسجيل الدخول، قم بإعداد الإشعارات
    await setupPushNotifications();
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  Future<void> updateProfile({
    required String fullName,
    required String bio,
    required String username,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User is not authenticated');
    }

    await _supabase.from('profiles').upsert({
      'id': user.id,
      'username': username.trim(),
      'full_name': fullName.trim(),
      'bio': bio.trim(),
      'avatar_url': avatarUrl,
    });
  }
}

// ============================================
// معالج الإشعارات في الخلفية
// ============================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // هنا تقدر تعرض إشعار محلي أو تسجيل في logs
}
