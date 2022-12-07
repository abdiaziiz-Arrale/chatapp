import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({required this.Userprofile, Key? key}) : super(key: key);
  final Map Userprofile;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}


class _ProfileViewState extends State<ProfileView> {
  final block = false.obs;
  void blockuser(){

    final sender = FirebaseAuth.instance.currentUser!.uid;
    final String receiver = widget.Userprofile['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    usersCol
        .doc(receiver)
        .collection('chats')
        .doc(sender)
        .set({'block': true}, SetOptions(merge: true));
    block.value= true;

  }  void unblock(){

    final sender = FirebaseAuth.instance.currentUser!.uid;
    final String receiver = widget.Userprofile['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    usersCol
        .doc(receiver)
        .collection('chats')
        .doc(sender)
        .set({'block': false}, SetOptions(merge: true));
    block.value= true;

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final sender = FirebaseAuth.instance.currentUser!.uid;
    final String receiver = widget.Userprofile['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    usersCol
        .doc(receiver)
        .collection('chats')
        .doc(sender)
        .snapshots()
        .listen((event) {
      block.value = event.data()?['block'] == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        toolbarHeight: 40,
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                CircleAvatar(
                    radius: 92,
                    backgroundImage: NetworkImage(widget.Userprofile['picture'])),
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(widget.Userprofile['name']),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        child: Icon(
                          Icons.call,
                          size: 50,
                          color: Colors.blueAccent,
                        ),
                        height: 80,
                        width: 40),
                    SizedBox(
                      width: 50,
                    ),
                    Icon(Icons.video_call, size: 50, color: Colors.blueAccent),
                    SizedBox(
                      width: 50,
                    ),
                    Icon(Icons.search, size: 50, color: Colors.blueAccent),
                  ],
                ),
                ListTile(
                  shape: StadiumBorder(),
                  title: Text(widget.Userprofile['Bio']),
                  leading: Icon(Icons.add),
                  // title: Text(Userprofile['Bio']),
                ),
              ],
            ),
          ),
          Obx(() {
            return  GestureDetector(
                onTap: block.isFalse? blockuser :unblock,
                child: Obx(() {
                  return ListTile(
                    shape: Border.all(color: Colors.black),
                    leading: block.isFalse?Icon(Icons.block ):Icon(Icons.undo_outlined),
                    title: Text("Block ${widget.Userprofile['name']}",
                        style: TextStyle(color: Colors.red)),
                  );
                })
            );
          }),
          SizedBox(
            height: 10,
          ),
          ListTile(
            shape: Border.all(color: Colors.black),
            leading: Icon(Icons.sentiment_satisfied),
            title: Text("Report ${widget.Userprofile['name']}",
                style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
