import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skypeclone/models/contact.dart';
import 'package:skypeclone/models/user.dart';
import 'package:skypeclone/provider/user__provider.dart';
import 'package:skypeclone/resources/firebase_methods.dart';
import 'package:skypeclone/resources/firebase_repository.dart';
import 'package:skypeclone/screens/chatscreens/chat_screen.dart';
import 'package:skypeclone/screens/chatscreens/widgets/cached_image.dart';
import 'package:skypeclone/screens/pageviews/widgets/online_dot_indicator.dart';
import 'package:skypeclone/widgets/custom_tile.dart';

class CallLogView extends StatelessWidget {
  final Contact contact;

  final FirebaseRepository _repository = FirebaseRepository();

  CallLogView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _repository.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;

          return ViewLayout(
            contact: user,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final User contact;
  final FirebaseMethods _firebaseMethods = FirebaseMethods();

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      title: Text(
        (contact != null ? contact.name : null) != null ? contact.name : "..",
        style:
            TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: Row(
        children: <Widget>[
          Icon(Icons.call_missed),
          Text(DateTime.now().toIso8601String()),
        ],
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndicator(
              uid: contact.uid,
            ),
          ],
        ),
      ),
    );
  }
}
