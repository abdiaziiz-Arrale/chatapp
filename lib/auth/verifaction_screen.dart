import 'dart:async';

import 'package:SomChat/auth/request_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../home/home.dart';


class VerificationScreen extends StatefulWidget {
  VerificationScreen(
      {Key? key, required this.verificationId, required this.phonenumber})
      : super(key: key);

  final String verificationId;
  final String phonenumber;
  final resend = false.obs;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final controller = TextEditingController();
  final error = false.obs;

  final start = 10.obs;

  late Timer timer;
  final loading = false.obs;
  void signIn() async {
    loading.value= true;
    final auth = FirebaseAuth.instance;
    final credential = PhoneAuthProvider.credential(

      verificationId: widget.verificationId,
      smsCode: controller.text,
    );

    try {
      await auth.signInWithCredential(credential);
      Get.offAll(HomeScreen());
    } catch (e) {
      print(e);
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (start.value == 1) {
        timer.cancel();
        widget.resend.value = true;
      }

      --start.value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Verify Your phone Number',
            style: TextStyle(color: Colors.blue),
          ),
          centerTitle: true,
          actions: [Icon(Icons.menu)],
        ),
        body: Column(

          children: [
            // Spacer(),
            Container(
              height: 130,
              child: Image.asset(
                'assets/images/send.png',
                height: 100,
              ),
            ),
            // SizedBox(height: 60,),
            Text('Verification',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(
                'You will get Six Digit Verification Code in ${widget.phonenumber} \n That Its Time-limited',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              Pinput(
                length: 6,
             controller: controller,

                showCursor: true,
                onCompleted: (pin) => signIn(),
              ),
            ),

            Obx(() {
              if (start.value <= 1)
                return GestureDetector(
                  onTap: ()=> Get.to(RequestScreen()),
                  child: ListTile(
                    leading: Icon(Icons.message),
                    title:
                    TextButton(onPressed: () {}, child: Text("Resend Code")),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(99)),
                      child: Center(
                        child: Text(
                          start.value.toString(),
                          style: const TextStyle(),
                        ),
                      ),
                    ),
                  ),
                );
              return ListTile(
                trailing: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(99)),
                  child: Center(
                    child: Text(
                      start.value.toString(),
                      style: const TextStyle(),
                    ),
                  ),
                ),
              );
            }),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                    Get.offAll(RequestScreen());
                    },
                    child: Text(
                      "Edit Phone Number ?",
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
            Spacer(),
            Obx(() {
              return MaterialButton(
                onPressed:  loading.isTrue ? null : () {
                  signIn();
                },
                color: Colors.blue,
                minWidth: 150,
                height: 50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: loading.isTrue? CircularProgressIndicator(color: Colors.pink,): Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              );
            }),
            SizedBox(height: 30,)

          ],
        ));
  }
}
