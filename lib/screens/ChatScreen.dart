import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:ello/services/GetMyInfo.dart';
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
  Stream<DocumentSnapshot> peerSnapshot;
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
                                GetMyInfo.myName
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
    fireStoreService.getPeerUserInfo(widget.chatRoomId).then((value) {
      setState(() {
        peerSnapshot = value;
      });
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
                    CircleAvatar(),
                  ],
                ),
              ),
              title: StreamBuilder(
                stream: peerSnapshot,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(
                          snapshot.data
                              .data()['user_name']
                              .toString()
                              .replaceAll(GetMyInfo.myName, ""),
                          textAlign: TextAlign.start,
                        )
                      : Container();
                },
              ),
            ),
            body: Container(
              color: Colors.black45,
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
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: messageController,
                                        decoration: InputDecoration(
                                            hintText: "Type here",
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
                            radius: 22,
                            child: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () async {
                                  if (messageController.text.isNotEmpty) {
                                    Map<String, dynamic> chatMessage = {
                                      'content': messageController.text,
                                      'send_by': GetMyInfo.myName,
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
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
          color: sendByMe ? Colors.blue : Colors.green,
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
