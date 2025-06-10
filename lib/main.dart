// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main_nurse_page.dart';
import 'package:flutter_app/splash_screen.dart';
import 'package:flutter_app/screens/login_page.dart';
import 'package:flutter_app/screens/welcome_page.dart';
import 'package:flutter_app/screens/register_page.dart';

// with Device Preview enabled
// void main() => runApp(
//   DevicePreview(
//     enabled: !kReleaseMode,
//     builder: (context) => MyApp(),
//     // Wrap your app
//   ),
// );

// without Device Preview enabled
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nurse Shift System',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/screens/welcome_page',
      routes: {
        '/': (context) => const SplashScreen(),
        '/splash_screen': (context) => const SplashScreen(),
        '/welcome_page': (context) => const WelcomePage(),
        '/register_page': (context) => const RegisterPage(),
        '/login_page': (context) => const LoginPage(),
        '/main_nurse_page': (context) => const MainNursePage(),
      },
    );
  }
}
