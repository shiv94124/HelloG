import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/screens/ChatScreen.dart';
import 'package:ello/screens/register.dart';
import 'package:ello/screens/searchPage.dart';
import 'package:ello/services/FirebaseAuthService.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:ello/services/GetMyInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream<QuerySnapshot> chatRoomList;
  FireStoreService fireStoreService = FireStoreService();
  SharedPreferences prefs;
  Stream<DocumentSnapshot> currentUserData;
  Map<String, dynamic> userData;

  Widget chatRoomListWidget() {
    return StreamBuilder(
        stream: chatRoomList,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                            ),
                            title: Text(
                              snapshot.data.docs[index]
                                  .data()['user_name']
                                  .toString()
                                  .replaceAll(GetMyInfo.myName, ""),
                              style: TextStyle(fontSize: 18),
                            ),
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ChatScreen(
                                        chatRoomId: snapshot.data.docs[index]
                                            .data()['chat_room_id'],
                                      )));
                            },
                          ),
                          Divider(
                            height: 0.0,
                            color: Colors.black45,
                            indent: 95.0,
                            endIndent: 10.0,
                          ),
                        ],
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  initState() {
    fireStoreService
        .getChatRoomList(FirebaseAuth.instance.currentUser.uid)
        .then((value) {
      setState(() {
        chatRoomList = value;
      });
    });
    fireStoreService.getUserInfo().then((value) {
      setState(() {
        currentUserData = value;
        currentUserData.listen((event) {
          setState(() {
            userData = event.data();
            GetMyInfo.myName = userData['name'];
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "HelloG",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final _auth = FirebaseAuthService();
              await _auth.signOut();
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => SignUp()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (BuildContext context) => SearchPage()));
        },
        child: Icon(Icons.search),
      ),
      body: chatRoomListWidget(),
    );
  }
}
