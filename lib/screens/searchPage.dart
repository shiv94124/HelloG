import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:ello/services/GetMyInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatScreen.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  final FireStoreService fireStoreService = FireStoreService();
  QuerySnapshot searchQuerySnapshot;
  bool haveUserSearched = false;
  SharedPreferences prefs;

  Widget userTile(String name, String mobileNo) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 20),
      ),
      subtitle: Text(
        mobileNo,
        style: TextStyle(fontSize: 16),
      ),
      trailing: ElevatedButton(
        onPressed: () async {
          prefs = await SharedPreferences.getInstance();
          List<String> usersId = [
            prefs.getString('id'),
            searchQuerySnapshot.docs[0].data()['id']
          ];
          String chatRoomId = getChatRoomId(
              FirebaseAuth.instance.currentUser.uid,
              searchQuerySnapshot.docs[0].data()['id'].toString());
          Map<String, dynamic> chatRoom = {
            'user_name':
                '${GetMyInfo.myName}${searchQuerySnapshot.docs[0].data()['name']}',
            'users_id': usersId,
            'chat_room_id': chatRoomId,
          };
          fireStoreService.addChatRoom(chatRoom, chatRoomId);
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
              builder: (context) => ChatScreen(
                    chatRoomId: chatRoomId,
                  )));
        },
        child: Text("Say Hello"),
      ),
    );
  }

  Widget userInviteTile(String mobileNo) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
      ),
      title: Text(
        mobileNo,
        style: TextStyle(fontSize: 20),
      ),
      trailing: ElevatedButton(
        onPressed: () {},
        child: Text("Invite"),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget searchWidget() {
      return searchQuerySnapshot.docs.length != 0
          ? ListView.builder(
              itemCount: searchQuerySnapshot.docs.length,
              itemBuilder: (context, index) {
                return userTile(
                  searchQuerySnapshot.docs[index].data()['name'],
                  searchQuerySnapshot.docs[index]
                      .data()['mobile_no']
                      .toString()
                      .substring(3, 13),
                );
              })
          : userInviteTile(searchController.text);
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                fireStoreService
                    .getUserByMobileNo(searchController.text)
                    .then((value) {
                  searchQuerySnapshot = value;
                  setState(() {
                    haveUserSearched = true;
                  });
                });
              }
            },
          ),
        ],
        title: TextField(
          decoration: InputDecoration(
              hintText: "Search by Mobile No", border: InputBorder.none),
          controller: searchController = TextEditingController(),
        ),
      ),
      body: haveUserSearched
          ? searchWidget()
          : Container(
              child: Center(child: Text("No User has been searched yet!")),
            ),
    );
  }

  String getChatRoomId(String userId, String peerId) {
    if (userId.hashCode > peerId.hashCode) {
      return '${userId}_$peerId';
    } else {
      return '${peerId}_$userId';
    }
  }
}
