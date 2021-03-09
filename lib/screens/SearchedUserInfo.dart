import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchedUserInfo extends StatefulWidget {

  SearchedUserInfo({this.searchedUserInfoSnapshot});
  final QuerySnapshot searchedUserInfoSnapshot;

  @override
  _SearchedUserInfoState createState() => _SearchedUserInfoState();
}

class _SearchedUserInfoState extends State<SearchedUserInfo> {




  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white,child: Column(mainAxisAlignment: MainAxisAlignment.start,children: [
      SizedBox(height: 30,),
      CircleAvatar(radius: 50,),
SizedBox(height: 40),
      Text(widget.searchedUserInfoSnapshot.docs[0].data()['name']),
      Text(widget.searchedUserInfoSnapshot.docs[0].data()['about']),

    ],),);
  }
}
