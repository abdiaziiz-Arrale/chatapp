import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SomChat/conversation_screen.dart';
import 'package:SomChat/find_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final chats = [].obs;
  final loading = true.obs;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    usersCol.doc(uid).collection('chats').snapshots().listen((event) async {
      chats.clear();
      for (var doc in event.docs) {
        final user = await usersCol.doc(doc.id).get();
        chats.add({
          'id': doc.id,
          'Bio': user.data()?['Bio'],
          'name': user.data()?['name'] ?? 'Null',
          'picture': await FirebaseStorage.instance.ref('users').child(doc.id).getDownloadURL(),
          'lastMessage': doc.data()['lastMessage']
        });
      }
      loading.value = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.pink,
          centerTitle: true,
          title: Text('Som Chat')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(FindScreen());
        },
        backgroundColor: Colors.pink,

        child: Icon(Icons.add_circle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.
      miniCenterFloat,
      body: Obx(() {
        if (loading.isTrue) {
          return Center(child: CircularProgressIndicator(
            color: Colors.pink,
          ));
        } else {
          return _buildList();
        }
      }),
    );
  }

  _buildList() {
    return Obx(() {
      if (chats.isEmpty) {
        return Center(child: Text('No Chats!'));
      } else {
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (ctx, index) {
            final chat = chats[index];
            final id = chat['id'];
            final lastMessage = chat['lastMessage'];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(chat['picture']),
              ),
              onTap: () => Get.to(ConversationScreen(user: chat)),
              title: Text(chat['name']),
              subtitle: Text(lastMessage['message']),
              // trailing: Text(lastMessage['date'].toDate().toString()),
            );
          },
        );
      }
    });
  }
}
