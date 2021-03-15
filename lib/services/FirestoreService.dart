import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreService {
  final auth = FirebaseAuth.instance;
  final String mobileNo;
  FireStoreService({this.mobileNo});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserInfo(userData) async {
    CollectionReference users = _firestore.collection('users');
    await users
        .doc('${auth.currentUser.uid}')
        .set(userData, SetOptions(merge: true))
        .then((value) => print("user is added"))
        .catchError((error) => print("user is not added $error"));
  }

  getUserInfo() async {
    return await  _firestore
        .collection('users')
        .doc(auth.currentUser.uid)
        .get();

  }

  retrieveCurrentUserData(String currentUserId) async {
    return await _firestore.collection('users').where("id",isEqualTo: currentUserId).get();
  }

  getSearchedUserInfo(String searchedUserId) async {
    return await _firestore.collection('users').doc(searchedUserId).get();
  }

  getUserByMobileNo(String mobileNo) async {
    return await _firestore
        .collection('users')
        .where("mobile_no", isEqualTo: '+91$mobileNo')
        .get();
  }

  Future<void> addChatRoom(chatRoom, chatRoomId) {
    _firestore
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoom, SetOptions(merge: true))
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addMessage(String chatRoomId, data) async {
    await _firestore
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .add(data)
        .then((value) => print("Message is added successfully"))
        .catchError((error) => print("Message is not added $error"));
  }

  getChats(String chatRoomId) async {
    return _firestore
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time')
        .snapshots();
  }

  getChatRoomList(String currentUserId) async {
    return _firestore
        .collection('chatRoom')
        .where('users_id', arrayContains: currentUserId)
        .snapshots();
  }

  getPeerUserInfo(String chatRoomId) async {
    return _firestore.collection('chatRoom').doc(chatRoomId).get().asStream();
  }

  updateChatRoomData(String chatRoomId, chatRoomData) async {
    await _firestore
        .collection('chatRoom')
        .doc(chatRoomId)
        .update(chatRoomData);
  }

  getPeerUserName(String chatRoomId) async {
    String peerUserId;
    peerUserId=chatRoomId.replaceAll("_", "").replaceAll(FirebaseAuth.instance.currentUser.uid, "");
    return await _firestore.collection('users').where('id',isEqualTo: peerUserId).get();
  }
  updateCharRoomUserName() async {
    return await _firestore.collection('chatRoom').where('id',arrayContains: FirebaseAuth.instance.currentUser.uid).get();
  }

}
