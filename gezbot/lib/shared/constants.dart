import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0)),
);

//.copyWith(hintText: 'Email', prefixIcon: Icon(Icons.email))
TextStyle messageBoxName = const TextStyle(
  color: messageBoxNameColor,
  fontWeight: FontWeight.bold,
);
TextStyle messageBoxMessage = const TextStyle(
  color: messageBoxMessageColor,
);
BoxDecoration messageBoxSenderMessage = const BoxDecoration(
  color: messageBoxSenderColor,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  ),
);
BoxDecoration messageBoxRecieverMessage = const BoxDecoration(
  color: messageBoxRecieverColor,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
    bottomRight: Radius.circular(20),
  ),
);

TextStyle buildMontserrat(
  Color color, {
  FontWeight fontWeight = FontWeight.normal,
}) {
  return TextStyle(
    fontSize: 18,
    color: color,
    fontWeight: fontWeight,
  );
}

var montserrat = const TextStyle(
  fontSize: 18,
);
const kBackgroundColor = Color(0xFFD2FFF4);
const kPrimaryColor = Color(0xFF2D5D70);
const kSecondaryColor = Color.fromRGBO(38, 93, 171, 1);

const messageBoxSenderColor = Color.fromARGB(190, 127, 184, 223);
const messageBoxRecieverColor = Color.fromARGB(190, 153, 153, 153);
const messageBoxNameColor = Color.fromARGB(255, 255, 255, 255);
const messageBoxMessageColor = Color.fromARGB(255, 255, 255, 255);
const darkColor = Color(0xFF49535C);

enum QuestionType { openEnded, date, multipleChoice, numberInput, yesNo }
