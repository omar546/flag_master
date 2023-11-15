import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../styles/colors.dart';


void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
        (Route<dynamic> route) => false);

Widget customButton(
    {required final String text,
      required BuildContext context,
      double widthRatio = double.infinity,
      double height = 50.0,
      required final VoidCallback onPressed}) {
  return SizedBox(
    height: height,
    width: MediaQuery.of(context).size.width * widthRatio,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(), backgroundColor: MyColors.fire),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'bitter-bold',
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    ),
  );
}

Widget customTextButton({
  required String text,
  required dynamic onPressed,
  Color color = MyColors.fire,
}) {
  return TextButton(
    onPressed: onPressed,
    child: Text(
      text,
      style: TextStyle(color: color),
    ),
  );
}

