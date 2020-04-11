import 'package:flutter/material.dart';

class ProgressCircular extends StatelessWidget {
  final double size;
  final Color color;

  const ProgressCircular({
    @required this.size,
    @required this.color,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: color,
        ),
      ),
    );
  }
}
