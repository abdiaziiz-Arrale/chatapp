import 'dart:async';
import 'dart:io';


import 'package:SomChat/profile/profileView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:image_picker/image_picker.dart';




class ConversationScreen extends StatefulWidget {
  const ConversationScreen({required this.user, Key? key}) : super(key: key);
  final Map user;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  final messages = [].obs;
  final typing = false.obs;
  final block = false.obs;
  final online = false.obs;

  final image = Rx<XFile?>(null);
  final controller = TextEditingController();

  void blockuser() {
    final sender = FirebaseAuth.instance.currentUser!.uid;
    final String receiver = widget.user['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    usersCol
        .doc(receiver)
        .collection('chats')
        .doc(sender)
        .set({'block': true}, SetOptions(merge: true));
  }

  void updatetyping() {
    final sender = FirebaseAuth.instance.currentUser!.uid;
    final String receiver = widget.user['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    usersCol
        .doc(receiver)
        .collection('chats')
        .doc(sender)
        .set({'typing': true}, SetOptions(merge: true));

    Timer(const Duration(seconds: 2), () {
      usersCol
          .doc(receiver)
          .collection('chats')
          .doc(sender)
          .set({'typing': false}, SetOptions(merge: true));
    });
  }

  Future<void> deleteForMe(message) async {
    final messageId = message['id'];

    final senderUid = FirebaseAuth.instance.currentUser!.uid;
    final receiverUid = widget.user['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    final senderChatsCol = usersCol.doc(senderUid).collection('chats');
    final senderMessageDoc = senderChatsCol.doc(receiverUid);

    final messagesCol = senderMessageDoc.collection('messages');
    await messagesCol
        .doc(messageId)
        .update({'message': 'This message was deleted'});
    await messagesCol
        .doc(messageId)
        .update({'image': 'This message was deleted'});
  }

  void deleteForAll(message) async {
    await deleteForMe(message);

    final messageId = message['id'];

    final senderUid = FirebaseAuth.instance.currentUser!.uid;
    final receiverUid = widget.user['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    final receiverChatsCol = usersCol.doc(receiverUid).collection('chats');
    final receiverMessageDoc = receiverChatsCol.doc(senderUid);

    final messagesCol = receiverMessageDoc.collection('messages');
    await messagesCol
        .doc(messageId)
        .update({'message': 'This message was deleted'}); await messagesCol
        .doc(messageId)
        .update({'image': 'This message was deleted'});
  }
  void sendMessage(XFile? file, String text) async {

    controller.clear();
    image.value = null;

    final senderUid = FirebaseAuth.instance.currentUser!.uid;
    final receiverUid = widget.user['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    final messageId = usersCol.doc().id;
    final message = {
      'message': text,
      'sender': senderUid,
      'date': FieldValue.serverTimestamp(),
    };

    if (file != null) {
      final storage = FirebaseStorage.instance;
      final imageRef = storage.ref('chatImages').child(messageId);

      await imageRef.putFile(File(file.path));

      final imageUrl = await imageRef.getDownloadURL();
      message['image'] = imageUrl;
    }

    // Sender chat
    final senderChatsCol = usersCol.doc(senderUid).collection('chats');
    final senderMessageDoc = senderChatsCol.doc(receiverUid);
    await senderMessageDoc.set({'lastMessage': message});
    await senderMessageDoc.collection('messages').doc(messageId).set(message);

    // Receiver chat
    final block =
    usersCol.doc(receiverUid).collection('chats').doc(senderUid).snapshots().listen((event) {
      if(event.data()?['block']== false){
        print("your blocked");
      }
    });
    final receiverChatsCol = usersCol.doc(receiverUid).collection('chats');
    final receiverMessageDoc = receiverChatsCol.doc(senderUid);

    await receiverMessageDoc.set({'lastMessage': message});
    await receiverMessageDoc.collection('messages').doc(messageId).set(message);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final sender = FirebaseAuth.instance.currentUser!.uid;
    final String receiver = widget.user['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');

    if (state == AppLifecycleState.resumed) {
      usersCol.doc(sender).set({'online': true}, SetOptions(merge: true));
    } else {
      usersCol.doc(sender).set({'online': false}, SetOptions(merge: true));
    }
  }
  @override
  void initState() {
    super.initState();
    updatetyping();
    WidgetsBinding.instance.addObserver(this);
    blockuser();
    final sender = FirebaseAuth.instance.currentUser!.uid;
    final String receiver = widget.user['id'];

    final db = FirebaseFirestore.instance;
    final usersCol = db.collection('users');
    usersCol
        .doc(sender)
        .collection('chats')
        .doc(receiver)
        .snapshots()
        .listen((event) {
      typing.value = event.data()?['typing'] == true;
    });
    usersCol
        .doc(sender)
        .collection('chats')
        .doc(receiver)
        .collection('messages')
        .orderBy('date')
        .snapshots()
        .listen((event) {
      messages.clear();
      for (final doc in event.docs) {
        final message = {'id': doc.id, ...doc.data()};
        messages.insert(0, message);
      }
    });
    usersCol.doc(receiver).snapshots().listen((event) {
      online.value = event.data()?['online'] == true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white54,
      appBar: AppBar(
          backgroundColor: Colors.pink,
          title: GestureDetector(
            onTap: () => Get.to(ProfileView(Userprofile: widget.user)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.user['picture']),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user['name']),
                    Obx(() {
                      if (typing.isTrue) {
                        return Text(
                          'Typing...',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12),
                        );
                      } else {
                        return Obx(() {
                          return Text(
                            online.value ? 'Online' : '',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 12),
                          );
                        });
                      }
                    })
                  ],
                )
              ],
            ),
          ),
          actions: [

            Row(
              children: [
                IconButton(onPressed: (){

                },
                    icon: Icon(Icons.add_ic_call_outlined)),
                // SizedBox(width: 12,),
                IconButton(onPressed: (){

                }, icon: Icon(Icons.videocam_outlined),),
                // Icon(Icons.more_vert_sharp),
              ],
            )
          ]),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (ctx, index) {
                  final message = messages[index];
                  final date  = message['date'].toDate().toString();
                  final _convertedTimestamp = DateTime.parse(date); // Converting into [DateTime] object
                  final result = GetTimeAgo.parse(_convertedTimestamp);
                  return Column(
                    crossAxisAlignment: message['sender'] ==
                        FirebaseAuth.instance.currentUser!.uid
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      PopupMenuButton(
                        onSelected: (val) {
                          if (val == 0) {
                            deleteForMe(message);
                          } else {
                            deleteForAll(message);
                          }
                        },
                        itemBuilder: (ctx) {
                          return [
                            const PopupMenuItem(
                                child: Text('Delete for me'), value: 0),
                            if (message['sender'] ==
                                FirebaseAuth.instance.currentUser!.uid)
                              const PopupMenuItem(
                                  child: Text('Delete for everyone'), value: 1),
                          ];
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: message['sender'] ==
                                  FirebaseAuth.instance.currentUser!.uid
                                  ? Color(0xfff52b69a)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [

                              if (message['image'] != null)
                                Image.network(message['image' ?? 'null'], width: 200),

                              Text(
                                message['message'],
                                style: TextStyle(
                                    fontSize: 16,
                                    color: message['sender'] ==
                                        FirebaseAuth.instance.currentUser!.uid
                                        ? Colors.white
                                        : Colors.black),
                              ),

                              Text(
                               result,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: message['sender'] ==
                                        FirebaseAuth.instance.currentUser!.uid
                                        ? Colors.white
                                        : Colors.black),
                              ),




                  ]
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(4, 8, 24, 24),
            child: Column(
              children: [
                Obx(() {
                  if (image.value != null) {
                    return Stack(
                      children: [
                        Image.file(File(image.value!.path ), height: 120 ),
                        Positioned(
                          right:0,
                          child: IconButton(onPressed: () {
                            image.value = null;
                          }, icon: Icon(Icons.clear,color: Colors.greenAccent,)),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then((XFile? value) {
                            image.value = value;
                          });
                        },
                        icon: Icon(Icons.image)),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (val) {
                          updatetyping();
                        },
                        decoration: InputDecoration(hintText: 'Enter messages'),
                      ),
                    ),
                    SizedBox(width: 20),
                    FloatingActionButton(
                      onPressed: () => sendMessage(image.value, controller.text),
                      mini: true,
                      elevation: 0,
                      child: Icon(Icons.send,color: Colors.pink,),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
