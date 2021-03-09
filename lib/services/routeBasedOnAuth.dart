import 'package:ello/screens/chatroom.dart';
import 'package:ello/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RouteWidget{
  checkAuth() {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null) {
              return ChatRoom();
            }
            else
              return SignUp();
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
