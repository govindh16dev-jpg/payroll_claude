import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:payroll/features/login/controller/sso_controller.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:payroll/service/app_lifecycle_controller.dart';
import 'package:payroll/service/token_manager.dart';
import 'package:payroll/theme/theme_controller.dart';
import 'package:payroll/util/custom_widgets.dart';
import 'package:sizer/sizer.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: FirebaseConstants.apiKey,
          authDomain: FirebaseConstants.authDomain,
          projectId: FirebaseConstants.projectId,
          storageBucket: FirebaseConstants.storageBucket,
          messagingSenderId: FirebaseConstants.messagingSenderId,
          appId: FirebaseConstants.appId,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: FirebaseConstants.apiKey,
          projectId: FirebaseConstants.projectId,
          messagingSenderId: FirebaseConstants.messagingSenderId,
          appId: FirebaseConstants.appIdiOS,
          iosBundleId: "com.azatecon.payroll",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  // Initialize global controllers
  Get.put(ProgressService());
  Get.put(NetworkService());
  Get.put(TokenManager());
  Get.put(AppLifecycleController());
  Get.put(SSOController());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController themeController = Get.put(ThemeController());
  final SSOController ssoController = Get.find<SSOController>();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isNavigationReady = false;
  Uri? _pendingDeepLink;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('🔗 Deep link received: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('❌ Deep link error: $err');
      },
    );

    await Future.delayed(const Duration(milliseconds: 800));
    _isNavigationReady = true;

    // 🔥 check if deep link was already used
    const storage = FlutterSecureStorage();
    final alreadyConsumed =
        await storage.read(key: PrefStrings.ssoLinkConsumed) == 'true';

    if (alreadyConsumed) {
      debugPrint('⏭️ Initial SSO link already consumed, skipping');
      return;
    }

    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        debugPrint('🔗 Initial link: $uri');

        if (_isNavigationReady) {
          _handleDeepLink(uri);
        } else {
          _pendingDeepLink = uri;
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) async {
    final ssoToken = uri.queryParameters['sso_token'];

    if (ssoToken != null && ssoToken.isNotEmpty) {
      debugPrint('✅ SSO Token received: $ssoToken');
      debugPrint('🔗 Calling SSO login API with token...');

      if (!_isNavigationReady) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      if (Get.context != null) {
        try {
          await ssoController.handleSSOLogin(ssoToken);

          // 🔥 mark link as consumed after success
          const storage = FlutterSecureStorage();
          await storage.write(key: PrefStrings.ssoLinkConsumed, value: 'true');
        } catch (e) {
          debugPrint('❌ SSO Authentication failed: $e');
        }
      } else {
        // retry logic unchanged
      }
    } else {
      debugPrint('⚠️ No SSO token found in deep link');
    }
  }

  // Process pending deep link after first frame
  void _processPendingDeepLink() {
    if (_pendingDeepLink != null && _isNavigationReady) {
      final uri = _pendingDeepLink;
      _pendingDeepLink = null;
      _handleDeepLink(uri!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Process pending deep link after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingDeepLink();
    });

    return Sizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splashPage,
          getPages: AppPages.pages,
          theme: themeController.currentTheme.lightTheme,
          builder: (context, child) {
            return Obx(() => Stack(
                  children: [
                    child ?? const SizedBox.shrink(),
                    // SSO Loading Overlay
                    if (ssoController.isLoading.value)
                      Material(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              loadingIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Authenticating...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ));
          },
        );
      },
    );
  }
}
