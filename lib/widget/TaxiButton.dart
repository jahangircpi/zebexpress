import 'package:flutter/material.dart';

class TaxiButton extends StatelessWidget {
  final String title;
  final Color color;
  final double height;
  final Function onPressed;

  TaxiButton({this.title, this.height = 30, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: color,
      textColor: Colors.white,
      child: Container(
        height: height,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
    );
  }
}
