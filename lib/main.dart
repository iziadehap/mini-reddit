import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/services/cash.dart';
import 'package:mini_reddit_v2/core/services/supabase_services.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/theme/theme_provider.dart';
import 'package:mini_reddit_v2/features/auth/presentation/pages/splash_screen.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';

/// Root navigator for FCM / deep links (no [BuildContext] in background handlers).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Set in [main] when app opens from a quit state via notification (navigator not ready yet).
String? pendingNotificationPostId;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();
  await Firebase.initializeApp();
  await CashService().init();

  await FirebaseMessaging.instance.requestPermission();

  String? token = await FirebaseMessaging.instance.getToken();

  // ============================================
  // معالج الضغط على الإشعار (التطبيق مفتوح)
  // ============================================
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationTap(message.data);
  });

  // ============================================
  // معالج الإشعار اللي فتح التطبيق (التطبيق كان مقفول)
  // ============================================
  RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    final postId = initialMessage.data['post_id'] as String?;
    if (postId != null && postId.isNotEmpty) {
      pendingNotificationPostId = postId;
    }
  }

  debugPrint('🔥 FCM Token: $token');

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = pendingNotificationPostId;
      if (id != null) {
        pendingNotificationPostId = null;
        _pushPostDetails(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Mini Reddit',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

void _pushPostDetails(String postId) {
  rootNavigatorKey.currentState?.push(
    MaterialPageRoute(builder: (context) => PostDetailsScreen(postId: postId)),
  );
}

void _handleNotificationTap(Map<String, dynamic> data) {
  final type = data['type'];
  final postId = data['post_id'] as String?;

  print('🔔 Notification tapped: type=$type, postId=$postId');

  if (postId == null || postId.isEmpty) return;

  // Defer until [MaterialApp]'s navigator is attached.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pushPostDetails(postId);
  });
}
