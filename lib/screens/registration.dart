import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:ello/services/GetMyInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'chatroom.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({this.mobileNo});
  final String mobileNo;

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String oldName, oldImageLink, oldAbout;
  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _aboutEditingController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FireStoreService fireStoreService = FireStoreService();
  QuerySnapshot updateChatRoomUserName;
  File avatarImage;
  bool isAvatarImage = false;
  // ignore: non_constant_identifier_names
  String image_link="";
  List<String> chatRoomIds;
  List<String> userNames;
  DocumentSnapshot currentUserSnapshot;

  SharedPreferences prefs;
  User currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  String currentUserOldName;

  Future<void> getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        avatarImage = image;
        isAvatarImage = true;
      });
    }
    print("fffffffffffffffffffffff");
    await uploadImage();
  }

  Future<void> uploadImage() async {
    print("firsttttttttttttttttttttttttt");
    String imageName = FirebaseAuth.instance.currentUser.uid;
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(imageName);
    await ref.putFile(avatarImage).whenComplete(() async {
      print("Secondddddddddddddddddddddddddddddd");
      await ref.getDownloadURL().then((value) {
        print("Thirddddddddddddddddddddddddddddddd");
        setState(() {
          image_link = value;
        });
      });
    });
  }

  Future<void> proceed(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    Map<String, String> userDataMap = {
      "name": _nameEditingController.text,
      'about': _aboutEditingController.text,
      'mobile_no': widget.mobileNo,
      'id': currentUser.uid,
      'image_link': image_link,
      'create_at': DateTime.now().microsecondsSinceEpoch.toString(),
    };
    fireStoreService.addUserInfo(userDataMap);
    await prefs.setString('id', currentUser.uid);
    await prefs.setString('mobile_no', currentUser.phoneNumber);
    await prefs.setString('name', _nameEditingController.text);
    await prefs.setString('about', _aboutEditingController.text);
    await prefs.setString('image_link', image_link);
    GetMyInfo.myName = prefs.getString('name');
    GetMyInfo.myId = prefs.getString('id');
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).push(
        CupertinoPageRoute(builder: (BuildContext context) => ChatRoom()));
  }

  InputDecoration _inputDecoration(String labelText, Widget icon) {
    return InputDecoration(
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 1))),
        labelText: labelText,
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black,)),
        hintStyle: TextStyle(color: Color.fromRGBO(252, 252, 252, 1)),
        icon: icon,
        errorStyle: TextStyle(color: Color.fromRGBO(248, 218, 87, 1)),
        errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1))),
        focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              child: Center(
                  child: Stack(
                children: [
                  (image_link != "")
                      ? Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) {
                              return Container(
                                child: Center(child: CircularProgressIndicator()),
                                height: 200,
                                width: 200,
                              );
                            },
                            imageUrl: image_link,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(125)),
                    clipBehavior: Clip.hardEdge,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 200.0,
                          color: Colors.white,
                        ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: getImage,
                  ),
                ],
              )),
            ),
            SizedBox(
              height: 30,
            ),
            Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameEditingController,
                      decoration:
                          _inputDecoration("Nick Name", Icon(Icons.person,color: Colors.white,)),
                      validator: (val) {
                        return val.length < 3
                            ? "Name should have at least 3 char"
                            : null;
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _aboutEditingController,
                      decoration: _inputDecoration("About", Icon(Icons.info_outline_rounded,color: Colors.white,)),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                )),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                proceed(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.pink),
                child: Text(
                  "Welcome to HelloG",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
