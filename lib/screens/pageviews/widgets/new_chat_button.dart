import 'package:flutter/material.dart';
import 'package:skypeclone/utils/universal_variables.dart';

class NewChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: UniversalVariables.fabGradient,
          borderRadius: BorderRadius.circular((50))),
      child: Icon(
        Icons.edit,
        size: 25,
      ),
      padding: EdgeInsets.all(15),
    );
  }
}