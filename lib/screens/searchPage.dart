import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatScreen.dart';
import 'SearchedUserInfo.dart';

class SearchPage extends StatefulWidget {
  final DocumentSnapshot currentUserInfo;
  SearchPage({this.currentUserInfo});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  final FireStoreService fireStoreService = FireStoreService();
  QuerySnapshot searchQuerySnapshot;
  bool haveUserSearched = false;
  SharedPreferences prefs;
  String invitedName;

  Widget userTile(String name, String mobileNo) {
    return ListTile(
      leading: searchQuerySnapshot!=null && searchQuerySnapshot.docs[0].data()['image_link']!=""?
      ClipRRect(
        child: CachedNetworkImage(
          imageUrl: searchQuerySnapshot.docs[0].data()['image_link'],
          height: 55,
          width: 55,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(125)),
      ):Icon(Icons.account_circle_rounded,size:55,color: Colors.grey[500],)
      ,
      title: Text(
        name,
        style: TextStyle(fontSize: 20),
      ),
      subtitle: Text(
        mobileNo,
        style: TextStyle(fontSize: 16),
      ),
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => SearchedUserInfo(
                  searchedUserInfoSnapshot: searchQuerySnapshot,
                )));
      },
      trailing: ElevatedButton(
        onPressed: () async {
          prefs = await SharedPreferences.getInstance();
          List<String> usersId = [
            FirebaseAuth.instance.currentUser.uid,
            searchQuerySnapshot.docs[0].data()['id']
          ];
          String chatRoomId = getChatRoomId(
              FirebaseAuth.instance.currentUser.uid,
              searchQuerySnapshot.docs[0].data()['id'].toString());
          Map<String, dynamic> chatRoom = {
            'user_name':
                '${widget.currentUserInfo.data()['name']}${searchQuerySnapshot.docs[0].data()['name']}',
            'users_id': usersId,
            'chat_room_id': chatRoomId,
            'peer_user_id':searchQuerySnapshot.docs[0].data()['id'].toString(),
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
      leading:  Icon(Icons.account_circle_rounded,size: 55,color: Colors.grey[500],),
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
          : invitedName.length == 10
              ? userInviteTile(invitedName)
              : Container();
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                invitedName = searchController.text;
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
          autofocus: false,
          decoration: InputDecoration(
              hintText: "Search by Mobile No", border: InputBorder.none),
          controller: searchController = TextEditingController(),
        ),
      ),
      body: haveUserSearched
          ? Padding(
        padding: const EdgeInsets.all(5.0),
        child: searchWidget(),
      )
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
