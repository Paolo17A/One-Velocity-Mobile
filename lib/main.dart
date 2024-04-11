import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/firebase_options.dart';
import 'package:one_velocity_mobile/utils/navigator_util.dart';
import 'package:one_velocity_mobile/utils/theme_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: OneVelocity()));
}

class OneVelocity extends StatelessWidget {
  const OneVelocity({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'One Velocity',
        theme: themeData,
        routes: routes,
        initialRoute: NavigatorRoutes.home);
  }
}
