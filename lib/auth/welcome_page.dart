import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SomChat/auth/request_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(
              'assets/images/logo.png',

            ),

Spacer(),
            const Text(
              'Welcome to Som Chat App',
              style: TextStyle(fontSize: 24),
            ),
         Spacer(),
            MaterialButton(
              onPressed: () {
                Get.to(RequestScreen());
              },
              shape: RoundedRectangleBorder(borderRadius:
              BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(vertical: 20),
              color: Colors.blue,
              minWidth: 250,

              child:

              Text(
                'Get Start',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

            ),
            SizedBox(height: 28),

          ],
        ),
      ),
    );
  }
}
