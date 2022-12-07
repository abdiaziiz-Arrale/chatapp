import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SomChat/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyB3D95RTOTWibwY3iJF2MNIsHaYkHOApVw",
        authDomain: "real-chat-app-1a11e.firebaseapp.com",
        projectId: "real-chat-app-1a11e",
        storageBucket: "real-chat-app-1a11e.appspot.com",
        messagingSenderId: "1078097504059",
        appId: "1:1078097504059:web:d0c1af12916f9f0363b91e",
        measurementId: "G-6Q4SQZDWQV"
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
