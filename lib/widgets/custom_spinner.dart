import 'package:flutter/material.dart';

class MyCustomSpinner extends StatefulWidget {
  final List<String> titles;
  final TextStyle titleStyle;
  int selectedIndex;
  final bool isDialog;
  String addressType;

  MyCustomSpinner({
    @required this.titles,
    this.titleStyle,
    this.selectedIndex = 0,
    this.isDialog = false,
  });

  @override
  _MyCustomSpinnerState createState() => _MyCustomSpinnerState();
}

class _MyCustomSpinnerState extends State<MyCustomSpinner> {
  @override
  void initState() {
    widget.addressType = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      alignment: AlignmentDirectional.centerStart,
      height: 56,
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 10,
      ),
      padding: EdgeInsets.all(
        10,
      ),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [
        BoxShadow(
          color: Color(0x20779AF1),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ]),
      child: InkWell(
        onTap: () {
          if (widget.isDialog) {
            showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                      content: Container(
                    height: widget.titles.length * 45.0,
                    width: double.infinity,
                    child: Column(
                      children: widget.titles.map((title) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          width: double.infinity,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                widget.selectedIndex = widget.titles.indexOf(title);
                                widget.addressType = title;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                title,
                                style: widget.titleStyle,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ));
                });
          } else {
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(width / 2, height / 2, 0, 0),
                items: widget.titles.map((title) {
                  return PopupMenuItem(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      width: double.infinity,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            widget.selectedIndex = widget.titles.indexOf(title);
                            widget.addressType = title;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 25,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: Text(
                            title,
                            style: widget.titleStyle,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList());
          }
        },
        child: Container(
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Text(
                widget.addressType != null
                    ? widget.addressType.isNotEmpty ? widget.addressType : widget.titles[widget.selectedIndex]
                    : widget.titles[widget.selectedIndex],
                style: Theme.of(context).textTheme.title.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
              Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
