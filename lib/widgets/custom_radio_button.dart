import 'package:essentials/values_and_localization/localized.dart';
import 'package:flutter/material.dart';

class MyCustomRadioGroup extends StatefulWidget {
  final List<String> titles;
  final Axis direction;
  final TextStyle titleStyle;
  final int initialIndex;
  final Color borderColor;
  final Color selectedInnerColor;
  final double diameter;
  String selectedTitle;
  int selectedIndex;

  MyCustomRadioGroup({
    @required this.titles,
    this.direction = Axis.horizontal,
    this.titleStyle,
    this.initialIndex = -1,
    this.borderColor = Colors.black,
    this.selectedInnerColor = Colors.grey,
    this.diameter = 18,
  }) {
    selectedIndex = -1;
  }

  @override
  _MyCustomRadioGroupState createState() => _MyCustomRadioGroupState();
}

class _MyCustomRadioGroupState extends State<MyCustomRadioGroup> {
  int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var singleItem = widget.titles.map((title) {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: () {
          setState(() {
            _selectedIndex = widget.titles.indexOf(title);
            widget.selectedIndex = _selectedIndex;
            widget.selectedTitle = Localized.text(
              context: context,
              key: title,
            );
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: widget.diameter,
                width: widget.diameter,
                margin: EdgeInsets.all(
                  5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.borderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(
                    widget.diameter / 2,
                  ),
                ),
                child: _selectedIndex == widget.titles.indexOf(title)
                    ? Container(
                        margin: EdgeInsets.all(
                          2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.transparent,
                            width: 0,
                          ),
                          color: widget.selectedInnerColor,
                          borderRadius: BorderRadius.circular(
                            widget.diameter / 2,
                          ),
                        ),
                      )
                    : SizedBox(),
              ),
              Text(
                Localized.text(
                  context: context,
                  key: title,
                ),
                style: widget.titleStyle,
              ),
            ],
          ),
        ),
      );
    }).toList();
    if (widget.direction == Axis.horizontal) {
      return Row(
        children: singleItem,
      );
    } else {
      return Column(
        children: singleItem,
      );
    }
  }
}
