import 'package:flutter/material.dart';

class ShowToasts {
  BuildContext context;
  String message;
  var scaffoldKey;

  ShowToasts.error({
    @required this.message,
    @required this.context,
    this.scaffoldKey,
  }) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red.withOpacity(0),
      duration: Duration(milliseconds: 2000),
      content: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.red),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
    if (scaffoldKey == null) {
      Scaffold.of(context).showSnackBar(
        snackBar,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scaffoldKey.currentState.showSnackBar(
          snackBar,
        ),
      );
    }
  }

  ShowToasts.info({
    @required this.message,
    @required this.context,
    this.scaffoldKey,
  }) {
    var snackBar = SnackBar(
      backgroundColor: Colors.blue.withOpacity(0),
      duration: const Duration(milliseconds: 2000),
      content: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.blue,
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
    if (scaffoldKey == null) {
      Scaffold.of(context).showSnackBar(
        snackBar,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scaffoldKey.currentState.showSnackBar(
          snackBar,
        ),
      );
    }
  }
}
