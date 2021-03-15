import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  ChatScreen({this.chatRoomId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  final FireStoreService fireStoreService = FireStoreService();
  Stream<QuerySnapshot> chats;
  QuerySnapshot peerUserNameSnapshot;
  Stream<DocumentSnapshot> peerSnapshot;
  DocumentSnapshot currentUserInfo;
  SharedPreferences prefs;
  Stream<DocumentSnapshot> currentUserData;
  Map<String, dynamic> userData;
  bool isLoading = false;

  Widget chatStreamWidget() {
    return StreamBuilder(
        stream: chats,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                        message: snapshot.data.docs[index].data()['content'],
                        sendByMe: snapshot.data.docs[index].data()['send_by'] ==
                                FirebaseAuth.instance.currentUser.uid
                            ? true
                            : false);
                  })
              : Container();
        });
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    fireStoreService.getPeerUserName(widget.chatRoomId).then((value) {
      setState(() {
        peerUserNameSnapshot = value;
      });
    });
    fireStoreService.getUserInfo().then((value) {
      currentUserInfo = value;
    });
    fireStoreService.getChats(widget.chatRoomId).then((value) {
      setState(() {
        chats = value;
      });
    });
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == false
        ? Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 8,
                    ),
                    peerUserNameSnapshot != null &&
                            peerUserNameSnapshot.docs[0].data()['image_link'] !=
                                ""
                        ? ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl: peerUserNameSnapshot.docs[0]
                                  .data()['image_link'],
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(125)),
                          )
                        : Icon(Icons.account_circle_rounded,size: 40,color: Colors.white,),
                  ],
                ),
              ),
              title: Text(
                peerUserNameSnapshot != null
                    ? peerUserNameSnapshot.docs[0].data()['name']
                    : "",
                textAlign: TextAlign.start,
              ),
            ),
            body: Container(
              color: Colors.pink[100],
              child: Column(
                children: [
                  Expanded(child: chatStreamWidget()),
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                color: Colors.pink,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: messageController,
                                        decoration: InputDecoration(
                                            hintText: "Type here...",
                                            hintStyle: TextStyle(color: Colors.white),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.pink,
                            radius: 22,
                            child: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () async {
                                  if (messageController.text.isNotEmpty) {
                                    Map<String, dynamic> chatMessage = {
                                      'content': messageController.text,
                                      'send_by':
                                          FirebaseAuth.instance.currentUser.uid,
                                      'time':
                                          DateTime.now().millisecondsSinceEpoch,
                                    };
                                    await fireStoreService.addMessage(
                                        widget.chatRoomId, chatMessage);
                                    setState(() {
                                      messageController.text = "";
                                    });
                                  }
                                }),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 12,
          bottom: 12,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10))
              : BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
          color: sendByMe ? Colors.pink : Colors.pink[50],
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal)),
      ),
    );
  }
}
