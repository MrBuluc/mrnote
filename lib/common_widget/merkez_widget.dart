import 'package:flutter/material.dart';

class MerkezWidget extends StatelessWidget {
  List<Widget> children;

  MerkezWidget({@required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children),
      ),
    );
  }
}
