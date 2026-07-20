import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_ideator_app/Setup/welcome_page.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  // BUG FIX: The original code replaced ALL error widgets with an empty
  // Container(), silently hiding every Flutter framework error during
  // development. This makes bugs invisible and impossible to debug.
  // Now: show a visible error card in debug mode, and a clean container
  // in release mode only.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return Material(
        child: Container(
          color: Colors.red.shade100,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Rendering Error:\n${details.exceptionAsString()}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    }
    // Release mode: show a neutral empty container
    return Container();
  };
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State&lt;MyApp&gt; {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      backgroundColor: Colors.white,
      image: Image.asset('images/splash.png'),
      loadingText: const Text('Loading...'),
      loaderColor: Colors.blue,
      photoSize: 150.0,
      navigateAfterSeconds: WelcomePage(),
    );
  }
}
