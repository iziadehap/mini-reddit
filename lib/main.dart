import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
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
  // test acc

  // email: noyox99951@fengnu.com
  // password: asdfghjkl
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CashService().init();

  String? token;
  if (!kIsWeb) {
    await FirebaseMessaging.instance.requestPermission();
    token = await FirebaseMessaging.instance.getToken();
  }

  // Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  //   debugPrint('🔐 Auth Event: ${data.event}');

  //   if (data.event == AuthChangeEvent.passwordRecovery) {
  //     debugPrint(
  //       '🔐 Password recovery detected! Navigating to create password screen...',
  //     );

  //     // استخدام rootNavigatorKey للانتقال (بدون context)
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       rootNavigatorKey.currentState?.push(
  //         MaterialPageRoute(
  //           builder: (context) => const CreateNewPasswordScreen(),
  //         ),
  //       );
  //     });
  //   }
  // });

  // ============================================
  // معالج الضغط على الإشعار (التطبيق مفتوح)
  // ============================================
  if (!kIsWeb) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });
  }

  // ============================================
  // معالج الإشعار اللي فتح التطبيق (التطبيق كان مقفول)
  // ============================================
  if (!kIsWeb) {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      final postId = initialMessage.data['post_id'] as String?;
      if (postId != null && postId.isNotEmpty) {
        pendingNotificationPostId = postId;
      }
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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = pendingNotificationPostId;
      if (id != null) {
        pendingNotificationPostId = null;
        _pushPostDetails(id);
      }
    });
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle deep link when app is started
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial app link: $e');
    }

    // Handle deep link while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Failed to listen to app links: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Got Deep Link: $uri');
    if (uri.scheme == 'mini-reddit' && uri.host == 'post') {
      final postId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (postId != null && postId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pushPostDetails(postId);
        });
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
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

  debugPrint('🔔 Notification tapped: type=$type, postId=$postId');

  if (postId == null || postId.isEmpty) return;

  // Defer until [MaterialApp]'s navigator is attached.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pushPostDetails(postId);
  });
}
