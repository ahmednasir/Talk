import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skypeclone/constants/strings.dart';
import 'package:skypeclone/enum_/user_state.dart';
import 'package:skypeclone/models/contact.dart';
import 'package:skypeclone/models/message.dart';
import 'package:skypeclone/models/user.dart';
import 'package:skypeclone/provider/image_upload.dart';
import 'package:skypeclone/utils/utilities.dart';

class FirebaseMethods {
//  initialize objects
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  static final Firestore firestore = Firestore.instance;

  static final CollectionReference _userCollection =
      firestore.collection(USERS_COLLECTION);
  static final CollectionReference _messageCollection =
      firestore.collection(MESSAGES_COLLECTION);
  static final CollectionReference _callLogCollection =
      firestore.collection(CALL_LOGS_COLLECTION);

  User user = User();
  StorageReference _storageReference;

  Future<FirebaseUser> getCurentuser() async {
    FirebaseUser currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken);

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  Future<bool> authenticateUser(FirebaseUser user) async {
    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .getDocuments();
    final List<DocumentSnapshot> docs = result.documents;

    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(FirebaseUser currentUser) async {
    String userName = Utils.getUsername(currentUser.email);
    user = User(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoUrl,
        username: userName);
    firestore
        .collection(USERS_COLLECTION)
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  Future<List<User>> fetchAllUsers(FirebaseUser user) async {
    List<User> userList = List<User>();
    QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != user.uid) {
        userList.add(User.fromMap(querySnapshot.documents[i].data));
      }
    }
    return userList;
  }

  Future<void> addMessageToDb(
      Message message, User sender, User receiver) async {
    var map = message.toMap();
    await _messageCollection
        .document(message.senderId)
        .collection(message.receiverId)
        .add(map);

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    return await _messageCollection
        .document(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  DocumentReference getContactsDocuments({String of, String forContact}) =>
      _userCollection
          .document(of)
          .collection(CONTACTS_COLLECTION)
          .document(forContact);

  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();
    await addToSendersContact(senderId, receiverId, currentTime);
    await addToReceiversContact(senderId, receiverId, currentTime);
  }

  Future<void> addToSendersContact(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocuments(of: senderId, forContact: receiverId).get();
    if (!senderSnapshot.exists) {
      Contact receiverContact = Contact(uid: receiverId, addedOn: currentTime);
      var receiverMap = receiverContact.toMap(receiverContact);
      getContactsDocuments(of: senderId, forContact: receiverId)
          .setData(receiverMap);
    }
  }

  Future<void> addToReceiversContact(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocuments(of: receiverId, forContact: senderId).get();
    if (!receiverSnapshot.exists) {
      Contact senderContact = Contact(uid: senderId, addedOn: currentTime);
      var senderMap = senderContact.toMap(senderContact);
      getContactsDocuments(of: receiverId, forContact: senderId)
          .setData(senderMap);
    }
  }

  Future<String> uploadImageToStorage(File image) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask _storageUploadTask = _storageReference.putFile(image);
      var url =
          await (await _storageUploadTask.onComplete).ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void setImageMessage(String url, String receiverId, String senderId) async {
    Message _message;
    _message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: "image");
    var map = _message.toImageMap();
    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.senderId)
        .collection(_message.receiverId)
        .add(map);

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.receiverId)
        .collection(_message.senderId)
        .add(map);
  }

  void uploadImage(ImageUploadProvider imageUploadProvider, File image,
      String receiverId, String senderId) async {
    imageUploadProvider.setToLoading();

    String url = await uploadImageToStorage(image);

    imageUploadProvider.setToIdle();

    setImageMessage(url, receiverId, senderId);
  }

  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurentuser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();
    return User.fromMap(documentSnapshot.data);
  }

  Future<User> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _userCollection.document(id).get();
      return User.fromMap(documentSnapshot.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
      .document(userId)
      .collection(CONTACTS_COLLECTION)
      .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween(
          {@required String senderId, @required String receiverId}) =>
      _messageCollection
          .document(senderId)
          .collection(receiverId)
          .orderBy(TIMESTAMP_FIELD)
          .snapshots();

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.document(userId).updateData({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.document(uid).snapshots();

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> fetchCallLogs({String userId}) => _callLogCollection
      .document(userId)
      .collection(CALL_LOGS_COLLECTION)
      .snapshots();
}
