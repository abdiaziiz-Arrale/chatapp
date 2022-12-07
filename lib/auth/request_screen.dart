import 'package:SomChat/auth/verifaction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_phone_code_picker/country_phone_code_picker.dart';

class RequestScreen extends StatelessWidget {
  RequestScreen({Key? key}) : super(key: key);

  final controller = TextEditingController();
  final countryController = TextEditingController();

  final loading = false.obs;

  void verifyPhoneNumber() {
    loading.value = true;



    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber:  controller.text,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException ex) {
        print(ex);
      },
      codeSent: (String verificationId, int? resendToken) {
        print('code sent');
        Get.to(VerificationScreen(verificationId: verificationId,phonenumber: controller.text,));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('Verify Your phone Number',style: TextStyle(color: Colors.blue),),
          centerTitle: true,
          actions: [Icon(Icons.menu)],
        ),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/send.png',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 75,


                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CountryPhoneCodePicker.withDefaultSelectedCountry(
                        defaultCountryCode:
                        Country(name: 'somali', countryCode: 'Som', phoneCode: '+252'),
showFlag: true,
                        showName: true,
                        style: const TextStyle(fontSize: 16),
                        searchBarHintText: 'Search by name',
                      ),
                    ),
                    Text(
                      "|",
                      style: TextStyle(fontSize: 23, color: Colors.grey),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Phone",
                          ),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child:             Obx(() {
                  return MaterialButton(
                    onPressed:  loading.isTrue ? null : () {
                      verifyPhoneNumber();
                    },
                    color: Colors.blue,
                    minWidth: 150,
                    height: 60,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: loading.isTrue? CircularProgressIndicator(color: Colors.pink,): Text(
                      'Send Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}