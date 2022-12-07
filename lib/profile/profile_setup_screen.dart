import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../home/home.dart';


class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  TextEditingController controller = new TextEditingController();
  TextEditingController bio = new TextEditingController();
  final selectedImage = ''.obs;


  void SaveProfile() async{

    final name = controller.text;

    final Bio = bio.text;
    if (name.isEmpty || selectedImage.value.isEmpty) {
      return;
    }

    final picture = File(selectedImage.value);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    final collection = db.collection('users');
    final document = collection.doc(uid);
    await document.set({
      'name': name,
      'Bio': Bio,
    });

    final storage = FirebaseStorage.instance;
    await storage.ref('users').child(uid).putFile(picture);


    Get.offAll(HomeScreen());

  }
  void pickImage() async{

    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image?.path == null) {
      return;
    }

    selectedImage.value = image!.path;
  }

  @override
  Widget build(BuildContext context) {
    String senderUid = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        centerTitle: true,
        title: Text('Create Profile'),
      ),
      body:
      Column(
        children: [
          Spacer(),
          GestureDetector(
              onTap: () => pickImage(),
              child: Obx(() {
                return CircleAvatar(
                  radius: 92,
                  backgroundImage: selectedImage.value.isNotEmpty
                      ? FileImage(File(selectedImage.value))
                      : null,
                  child: selectedImage.value.isEmpty
                      ? const Icon(Icons.person, size: 32)
                      : null,
                );
              })),
          Spacer(),
          ListTile(
            leading: Icon(Icons.person),
            title:  TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Enter Name"),
            ),
          ),

          ListTile(
            title: TextField(
              controller: bio,
              decoration: const InputDecoration(hintText: 'Enter Bio'),
            ),
            leading: Icon(Icons.account_box_outlined),
          ), ListTile(
            title: Text(senderUid),


            leading: Icon(Icons.phone),
          ),
          Spacer(),
          // const SizedBox(height: 24),
          MaterialButton(
            color: Colors.pink,
            onPressed: () => {
              SaveProfile()
            },
            child: Text('Save',style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 20,)
        ],
      ),

    );
  }
}