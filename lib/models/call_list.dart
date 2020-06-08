class CallLog {
  String callerId;
  String receiverId;
  String receiverName;
  String receiverPic;
  String callType;

  CallLog(
      {this.callerId,
      this.receiverId,
      this.receiverName,
      this.receiverPic,
      this.callType});

  // to map
  Map<String, dynamic> toMap(CallLog call) {
    Map<String, dynamic> callMap = Map();
    callMap["caller_id"] = call.callerId;
    callMap["receiver_id"] = call.receiverId;
    callMap["receiver_name"] = call.receiverName;
    callMap["receiver_pic"] = call.receiverPic;
    callMap["call_type"] = call.callType;
    return callMap;
  }

  CallLog.fromMap(Map callMap) {
    this.callerId = callMap["caller_id"];
    this.receiverId = callMap["receiver_id"];
    this.receiverName = callMap["receiver_name"];
    this.receiverPic = callMap["receiver_pic"];
    this.callType = callMap["call_type"];
  }
}
