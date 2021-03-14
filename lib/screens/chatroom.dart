import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/screens/ChatScreen.dart';
import 'package:ello/screens/profile.dart';
import 'package:ello/screens/register.dart';
import 'package:ello/screens/searchPage.dart';
import 'package:ello/services/FirebaseAuthService.dart';
import 'package:ello/services/FirestoreService.dart';
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
  QuerySnapshot peerUserNameSnapshot;
  DocumentSnapshot currentUserInfo;
  FireStoreService fireStoreService = FireStoreService();
  SharedPreferences prefs;
  Stream<DocumentSnapshot> currentUserData;
  Map<String, dynamic> userData;
  // ignore: non_constant_identifier_names
  double offset_x = 0, offset_y = 0, scale = 1;
  bool isOpened = false;

  Widget chatRoomListWidget() {
    return StreamBuilder(
        stream: chatRoomList,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    fireStoreService
                        .getPeerUserName(
                            snapshot.data.docs[index].data()['chat_room_id'])
                        .then((value) {
                      setState(() {
                        peerUserNameSnapshot = value;
                      });
                    });
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                            ),
                            title: Text(
                              peerUserNameSnapshot != null
                                  ? peerUserNameSnapshot.docs[0].data()['name']
                                  : "",
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
    fireStoreService.getUserInfo().then((value) {
      setState(() {
        currentUserInfo = value;
      });
    });
    fireStoreService
        .getChatRoomList(FirebaseAuth.instance.currentUser.uid)
        .then((value) {
      setState(() {
        chatRoomList = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 70),
          color: Colors.pinkAccent,
          child: Padding(
            padding: const EdgeInsets.only(left: 22.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            currentUserInfo != null
                                ? currentUserInfo.data()['name']
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            "online",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 125,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => ProfilePage()));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Profile",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Settings",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                SizedBox(
                  height: 275,
                ),
                GestureDetector(
                  onTap: () async {
                    final _auth = FirebaseAuthService();
                    await _auth.signOut();
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) => SignUp()));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Sign Out",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          if (isOpened) {
            setState(() {
              offset_x = 0;
              offset_y = 0;
              scale = 1;
              isOpened = false;
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          transform: Matrix4.translationValues(offset_x, offset_y, 0)
            ..scale(scale),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isOpened ? 30 : 0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isOpened ? 30 : 0),
            child: Scaffold(
              appBar: AppBar(
                leading: isOpened == false
                    ? IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          setState(() {
                            offset_x = 230;
                            offset_y = 150;
                            scale = 0.7;
                            isOpened = true;
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded),
                        onPressed: () {
                          setState(() {
                            offset_x = 0;
                            offset_y = 0;
                            scale = 1;
                            isOpened = false;
                          });
                        },
                      ),
                title: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "HelloG",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (BuildContext context) => SearchPage()));
                },
                child: Icon(Icons.search),
              ),
              body: chatRoomListWidget(),
            ),
          ),
        ),
      ),
    ]);
  }
}
