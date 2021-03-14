import 'package:ello/services/FirestoreService.dart';
import 'package:ello/services/GetMyInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatroom.dart';


class CurrentUserUpdatePage extends StatefulWidget {

  final String name,about;
  CurrentUserUpdatePage({this.name,this.about});

  @override
  _CurrentUserUpdatePageState createState() => _CurrentUserUpdatePageState();
}

class _CurrentUserUpdatePageState extends State<CurrentUserUpdatePage> {

  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _aboutEditingController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FireStoreService fireStoreService = FireStoreService();

  SharedPreferences prefs;
  User currentUser=FirebaseAuth.instance.currentUser;
  bool isLoading=false;

  Future<void> save(BuildContext context) async {
    setState(() {
      isLoading=true;
    });
    prefs=await SharedPreferences.getInstance();
    Map<String, String> userDataMap = {
      "name": _nameEditingController.text,
      'about': _aboutEditingController.text,
      'create_at': DateTime.now().microsecondsSinceEpoch.toString(),
    };
    fireStoreService.addUserInfo(userDataMap);
    await prefs.setString('id',currentUser.uid );
    await prefs.setString('mobile_no', currentUser.phoneNumber);
    await prefs.setString('name', _nameEditingController.text);
    await prefs.setString('about', _aboutEditingController.text);
    GetMyInfo.myName=prefs.getString('name');
    GetMyInfo.myId=prefs.getString('id');
    setState(() {
      isLoading=false;
    });
    Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>ChatRoom()));
  }

  InputDecoration _inputDecoration(String labelText, Widget icon) {
    return InputDecoration(
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 1))),
        labelText: labelText,
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(151, 151, 151, 1))),
        hintStyle: TextStyle(color: Color.fromRGBO(252, 252, 252, 1)),
        icon: icon,
        errorStyle: TextStyle(color: Color.fromRGBO(248, 218, 87, 1)),
        errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1))),
        focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1))));
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
            CircleAvatar(
              child: Icon(Icons.photo),
              radius: 50,
            ),
            SizedBox(
              height: 30,
            ),
            Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: _nameEditingController,
                      decoration:
                      _inputDecoration("Nick Name", Icon(Icons.person)),
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
                      controller: _aboutEditingController=TextEditingController(text: widget.about,),
                      decoration: _inputDecoration("About", Icon(Icons.info_outline_rounded)),
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
                save(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blue),
                child: Text(
                  "Save",
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
