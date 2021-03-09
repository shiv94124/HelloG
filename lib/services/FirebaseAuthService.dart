import 'package:ello/screens/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuthService({this.phoneNo});

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
  Future<User> verifyPhone(BuildContext context) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential).then((value) async {
        if (value != null) {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => RegistrationPage(
                    mobileNo: phoneNo,
                  )));
        }
      });
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