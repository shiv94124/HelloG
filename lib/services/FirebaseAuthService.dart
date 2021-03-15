import 'package:ello/screens/registration.dart';
import 'package:ello/services/FirestoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GetMyInfo.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuthService({this.phoneNo});
  FireStoreService fireStoreService=FireStoreService();

  void getUserInfo() {
    if (_auth.currentUser != null) {
      print(_auth.currentUser.uid);
    } else {
      print("error");
    }
  }

  Future<User> user() async {
    if (_auth.currentUser != null)
      return _auth.currentUser;
    else
      return null;
  }

  final String phoneNo;
  String verificationId;
  SharedPreferences prefs;
  Future<User> verifyPhone(BuildContext context) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      if (_auth.currentUser != null) {
        prefs = await SharedPreferences.getInstance();
        Map<String, String> userDataMap = {
          "name": phoneNo.toString().substring(3,13),
          'about': "HelloG 😀",
          'mobile_no': phoneNo,
          'id': _auth.currentUser.uid,
          'image_link': "",
          'create_at': DateTime.now().microsecondsSinceEpoch.toString(),
        };
        fireStoreService.addUserInfo(userDataMap);
        await prefs.setString('id', _auth.currentUser.uid);
        await prefs.setString('mobile_no', _auth.currentUser.phoneNumber);
        await prefs.setString('name', _auth.currentUser.phoneNumber);
        await prefs.setString('about', "HelloG 😀");
        await prefs.setString('image_link', "");
        GetMyInfo.myName = prefs.getString('name');
        GetMyInfo.myId = prefs.getString('id');
        Navigator.of(context)
            .push(CupertinoPageRoute(builder: (context) => RegistrationPage(mobileNo: _auth.currentUser.phoneNumber,)));
      }
    };
//
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print('Auth Exception is ${authException.message}');
    };
//
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('verification id is $verificationId');
      this.verificationId = verificationId;
    };
//
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
    };
//
    await _auth.verifyPhoneNumber(
      // mobile no. with country code
      phoneNumber: phoneNo,
      timeout: const Duration(seconds: 30),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    return _auth.currentUser;
  }

  Future<void> signIn(context, {@required String smsOTP}) async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsOTP,
    );
    await _auth.signInWithCredential(credential);
    if (_auth.currentUser != null) {
      prefs = await SharedPreferences.getInstance();
      Map<String, String> userDataMap = {
        "name": phoneNo.toString().substring(3,13),
        'about': "HelloG 😀",
        'mobile_no': phoneNo,
        'id': _auth.currentUser.uid,
        'image_link': "",
        'create_at': DateTime.now().microsecondsSinceEpoch.toString(),
      };
      fireStoreService.addUserInfo(userDataMap);
      await prefs.setString('id', _auth.currentUser.uid);
      await prefs.setString('mobile_no', _auth.currentUser.phoneNumber);
      await prefs.setString('name', _auth.currentUser.phoneNumber);
      await prefs.setString('about', "HelloG 😀");
      await prefs.setString('image_link', "");
      GetMyInfo.myName = prefs.getString('name');
      GetMyInfo.myId = prefs.getString('id');
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => RegistrationPage(mobileNo: _auth.currentUser.phoneNumber)));
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
