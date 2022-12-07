import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SomChat/home/home.dart';
import 'package:lottie/lottie.dart';

import 'auth/welcome_page.dart';
import 'profile/profile_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Timer(
        Duration(seconds: 20),
            () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext ctx) => SplashScreen())));
    super.initState();
    final auth = FirebaseAuth.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (auth.currentUser == null) {
        Get.offAll(WelcomePage());
      } else {
        final db = FirebaseFirestore.instance;
        final collection = db.collection('users');
        final uid = auth.currentUser!.uid;
        final document = collection.doc(uid);

        document.get().then((value) {
          if (!value.exists) {
            Get.off(ProfileSetupScreen());
          } else {
            Get.offAll(HomeScreen());
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
                'assets/images/animate.json',animate: true,repeat: true
                ),
            Text(
              'Som Chat App',
              style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 10, 126, 164)),
            ),
          ],
        ),
      ),
    );
  }
}
