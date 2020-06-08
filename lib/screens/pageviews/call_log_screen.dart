import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skypeclone/models/contact.dart';
import 'package:skypeclone/provider/user__provider.dart';
import 'package:skypeclone/resources/firebase_methods.dart';
import 'package:skypeclone/resources/firebase_repository.dart';
import 'package:skypeclone/screens/pageviews/widgets/call_log_view.dart';
import 'package:skypeclone/screens/pageviews/widgets/contact_view.dart';
import 'package:skypeclone/screens/pageviews/widgets/new_chat_button.dart';
import 'package:skypeclone/screens/pageviews/widgets/quiet_box.dart';
import 'package:skypeclone/screens/pageviews/widgets/user_circle.dart';
import 'package:skypeclone/utils/universal_variables.dart';
import 'package:skypeclone/widgets/appbar.dart';

//global
final FirebaseRepository _repository = FirebaseRepository();

class CallLogScreen extends StatelessWidget {
  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.notifications),
        color: Colors.white,
        onPressed: () {},
      ),
      title: UserCircle(),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, "/search_screen");
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          color: Colors.white,
          onPressed: () {},
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
//      floatingActionButton: NewChatButton(),
      body: ChatListContainer(),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream:
          _firebaseMethods.fetchCallLogs(userId: userProvider.getUser.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;
              if (docList.isEmpty) {
                return QuietBox();
              }

              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data);
                  return CallLogView(contact);
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
