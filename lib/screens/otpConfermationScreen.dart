import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ello/screens/chatroom.dart';
import 'package:ello/screens/registration.dart';
import 'package:ello/services/FirebaseAuthService.dart';
import 'package:ello/services/GetMyInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtpConfirmationScreen extends StatefulWidget {
  final String mobileNo;
  OtpConfirmationScreen({this.mobileNo});
  @override
  _OtpConfirmationScreenState createState() => _OtpConfirmationScreenState();
}

class _OtpConfirmationScreenState extends State<OtpConfirmationScreen> {
  TextEditingController _otpEditingController = TextEditingController();
  FirebaseAuthService _auth;
  QuerySnapshot userSnapshot;
  bool isLoading = false;

  signIn(BuildContext context, String otp) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (formKey.currentState.validate()) {
        await _auth.signIn(context, smsOTP: _otpEditingController.text);
        _auth.getUserInfo();
      }
    } catch (e) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter valid OTP $e")));
    }
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: '${FirebaseAuth.instance.currentUser.uid}')
          .get()
          .then((value) {
        userSnapshot = value;
      });
      if (userSnapshot.docs.length != 0) {
        Navigator.of(context)
            .push(CupertinoPageRoute(builder: (context) => ChatRoom()));
      } else {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => RegistrationPage(
                  mobileNo: widget.mobileNo,
                )));
      }
    }
    setState(() {
      isLoading = false;
    });
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

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuthService(phoneNo: widget.mobileNo);
    _auth.verifyPhone(context);
    if (FirebaseAuth.instance.currentUser != null) {
      setState(() {
        isLoading=true;
      });
      GetMyInfo.myId = FirebaseAuth.instance.currentUser.uid;
      FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: '${FirebaseAuth.instance.currentUser.uid}')
          .get()
          .then((value) {
        userSnapshot = value;
      });
      if (userSnapshot.docs.length != 0) {
        Navigator.of(context)
            .push(CupertinoPageRoute(builder: (context) => ChatRoom()));
      } else {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => RegistrationPage(
              mobileNo: widget.mobileNo,
            )));
      }
      setState(() {
        isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Verifying This Mobile No ${widget.mobileNo} ",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _otpEditingController,
                    decoration: _inputDecoration("OTP", null),
                    validator: (val) {
                      return val.length < 6 ? "Please enter valid OTP" : null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                if (formKey.currentState.validate()) {
                  signIn(context, _otpEditingController.text);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff007EF4),
                        const Color(0xff2A75BC)
                      ],
                    )),
                child: isLoading==false ? Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ):Text(
                  "Signing in...",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
