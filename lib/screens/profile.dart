import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'currentUserUpdatePage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DocumentSnapshot currentUserSnapshot;
  FireStoreService fireStoreService = FireStoreService();

  @override
  void initState() {
    fireStoreService.getUserInfo().then((value) {
      setState(() {
        currentUserSnapshot = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            CircleAvatar(
              radius: 80,
            ),
            SizedBox(height: 30),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name"),
                        Text(
                          currentUserSnapshot != null
                              ? currentUserSnapshot.data()['name']
                              : "",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "This is your user name. This will be visible to other's HelloG Account"),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => CurrentUserUpdatePage(name: currentUserSnapshot != null
                              ? currentUserSnapshot.data()['name']
                              : "",about: currentUserSnapshot != null
                              ? currentUserSnapshot.data()['about']
                              : "",)));
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 0.0,
              color: Colors.black45,
              indent: 95.0,
              endIndent: 10.0,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("About"),
                        Text(currentUserSnapshot != null
                            ? currentUserSnapshot.data()['about']
                            : ""),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => CurrentUserUpdatePage(name: currentUserSnapshot != null
                              ? currentUserSnapshot.data()['name']
                              : "",about: currentUserSnapshot != null
                              ? currentUserSnapshot.data()['about']
                              : "",)));
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 0.0,
              color: Colors.black45,
              indent: 95.0,
              endIndent: 10.0,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone_android_rounded),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mobile No"),
                        Text(
                          FirebaseAuth.instance.currentUser.phoneNumber
                              .toString()
                              .substring(3, 13),
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
