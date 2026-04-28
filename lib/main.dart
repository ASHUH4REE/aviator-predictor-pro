import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme.dart';
import 'core/router.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/prediction_provider.dart';
import 'services/notification_service.dart';

// NOTE: Run `flutterfire configure` to generate firebase_options.dart.
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for premium gaming feel.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Local storage.
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('app_cache');

  // Firebase init. After running `flutterfire configure`, switch to:
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();

  // Background push handler.
  await NotificationService.instance.initialize();

  runApp(const AviatorPredictorApp());
}

class AviatorPredictorApp extends StatelessWidget {
  const AviatorPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<PredictionProvider>(
          create: (_) => PredictionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Aviator Predictor Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
