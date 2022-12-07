// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class personscreen extends StatefulWidget {
//   const personscreen({Key? key}) : super(key: key);
//
//   @override
//   State<personscreen> createState() => _personscreenState();
// }
//
// class _personscreenState extends State<personscreen> {
//   final users = [].obs;
//
//   void getAllUsers() async {
//     final db = FirebaseFirestore.instance;
//     final collection = db.collection('users');
//     final results = await collection.get();
//
//     final storage = FirebaseStorage.instance;
//
//     for (final document in results.docs) {
//       if (document.id == FirebaseAuth.instance.currentUser!.uid) {
//         final user = {
//           'id': document.id,
//           'name': document.data()['name'],
//           'picture': await storage.ref('users').child(document.id).getDownloadURL()
//         };
//
//         users.add(user);
//       }
//
//       }
//
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getAllUsers();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: AppBar(),
//         body:
//                     Obx(() {
//                       if (users.isEmpty) {
//                         return Center(child: Text("No Profile Yet"));
//                       } else {
//                         return ListView.builder(
//                           itemCount: users.length,
//                           itemBuilder: (ctx, index) {
//                             final user = users[index];
//                             final bio = user['Bio']?? '';
//                             final name = user['name'] ?? '';
//                             final picture = user['picture'];
//
//                             return Column(
//
//                               children: [
//
//
//
//                                 ListTile(
//                                   leading: Icon(Icons.person),
//                                   title: Text(name),
//                                 ),
//                                 ListTile(
//                                   shape: StadiumBorder(),
//                                   title: Text(bio),
//                                   leading: Icon(Icons.add),
//                                   // title: Text(Userprofile['Bio']),
//                                 ),
//                                 Image.network(picture),
//                               ],
//                             );
//
//                           },
//                         );
//                       }
//                     }),
//
//
//         );
//   }
// }
//
// class getClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = new Path();
//
//     path.lineTo(0.0, size.height / 1.9);
//     path.lineTo(size.width + 125, 0.0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     // TODO: implement shouldReclip
//     return true;
//   }
// }
