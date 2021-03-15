import 'package:cached_network_image/cached_network_image.dart';
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
            currentUserSnapshot!=null && currentUserSnapshot.data()['image_link']!=""?
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: currentUserSnapshot.data()['image_link'],
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(125)),
            ): Icon(Icons.account_circle_rounded,size: 200,color: Colors.white,),
            SizedBox(height: 30),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person,color: Colors.white,),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name",style: TextStyle(color: Colors.white),),
                        Text(
                          currentUserSnapshot != null
                              ? currentUserSnapshot.data()['name']
                              : "",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "This is your user name. This will be visible to other's HelloG Account",style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 0.0,
              color: Colors.white,
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
                  Icon(Icons.info_outline_rounded,color: Colors.white,),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("About",style: TextStyle(color: Colors.white),),
                        Text(currentUserSnapshot != null
                            ? currentUserSnapshot.data()['about']
                            : "",style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 0.0,
              color: Colors.white,
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
                  Icon(Icons.phone_android_rounded,color: Colors.white,),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mobile No",style: TextStyle(color: Colors.white),),
                        Text(
                          FirebaseAuth.instance.currentUser.phoneNumber
                              .toString()
                              .substring(3, 13),
                          style: TextStyle(fontSize: 20,color: Colors.white),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => CurrentUserUpdatePage(name: currentUserSnapshot != null
                  ? currentUserSnapshot.data()['name']
                  : "",about: currentUserSnapshot != null
                  ? currentUserSnapshot.data()['about']
                  : "",image_link: currentUserSnapshot != null
                  ? currentUserSnapshot.data()['image_link']
                  : "",)));
        },
      ),
    );
  }
}
