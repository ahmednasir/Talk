import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skypeclone/constants/strings.dart';
import 'package:skypeclone/models/call.dart';
import 'package:skypeclone/models/call_list.dart';

class CallMethods {
  static final Firestore firestore = Firestore.instance;
  final CollectionReference callCollection =
      Firestore.instance.collection(CALL_COLLECTION);

  final CollectionReference callLogCollection =
      Firestore.instance.collection(CALL_LOGS_COLLECTION);

  Stream<DocumentSnapshot> callStream({String uid}) =>
      callCollection.document(uid).snapshots();

  Future<bool> makeCall({Call call}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await callCollection.document(call.callerId).setData(hasDialledMap);
      await callCollection.document(call.receiverId).setData(hasNotDialledMap);

      CallLog callLog = CallLog(
          callerId: call.callerId,
          receiverId: call.receiverId,
          receiverName: call.receiverName,
          receiverPic: call.receiverPic,
          callType: CALL_DIALLED);

      Map<String, dynamic> callLogMap = callLog.toMap(callLog);

      await firestore
          .collection(CALL_LOGS_COLLECTION)
          .document(call.callerId)
          .collection(DateTime.now().toString())
          .document(callLogMap.toString());


      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> endCall({Call call}) async {
    try {
      await callCollection.document(call.callerId).delete();
      await callCollection.document(call.receiverId).delete();

      CallLog callLog = CallLog(
          callerId: call.callerId,
          receiverId: call.receiverId,
          receiverName: call.receiverName,
          receiverPic: call.receiverPic,
          callType: CALL_RECEIVED);
      Map<String, dynamic> callLogMap = callLog.toMap(callLog);

      await callLogCollection.document(call.callerId).setData(callLogMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
