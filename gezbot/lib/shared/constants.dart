import 'package:flutter/material.dart';

const TextInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0)),
);

//.copyWith(hintText: 'Email', prefixIcon: Icon(Icons.email))
TextStyle MessageBoxName = const TextStyle(
  color: MessageBoxNameColor,
  fontWeight: FontWeight.bold,
);
TextStyle MessageBoxMessage = const TextStyle(
  color: MessageBoxMessageColor,
);
BoxDecoration MessageBoxSenderMessage = const BoxDecoration(
  color: MessageBoxSenderColor,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  ),
);
BoxDecoration MessageBoxRecieverMessage = const BoxDecoration(
  color: MessageBoxRecieverColor,
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

var montserrat = TextStyle(
  fontSize: 18,
);
const kBackgroundColor = Color(0xFFD2FFF4);
const kPrimaryColor = Color(0xFF2D5D70);
const kSecondaryColor = Color.fromRGBO(38, 93, 171, 1);

const MessageBoxSenderColor = Color.fromARGB(190, 127, 184, 223);
const MessageBoxRecieverColor = Color.fromARGB(190, 153, 153, 153);
const MessageBoxNameColor = Color.fromARGB(255, 255, 255, 255);
const MessageBoxMessageColor = Color.fromARGB(255, 255, 255, 255);
const darkColor = Color(0xFF49535C);

enum QuestionType { openEnded, date, multipleChoice, numberInput, yesNo }
