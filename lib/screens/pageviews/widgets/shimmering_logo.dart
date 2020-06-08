import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skypeclone/utils/universal_variables.dart';

class ShimmeringLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      child: Image.asset("assets/logo.png")
    );
  }
}