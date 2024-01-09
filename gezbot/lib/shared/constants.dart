import 'package:flutter/material.dart';

const TextInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2.0)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink, width: 2.0)));

//.copyWith(hintText: 'Email', prefixIcon: Icon(Icons.email))
TextStyle MessageBoxName = const TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
TextStyle MessageBoxMessage = const TextStyle(
  color: Colors.white,
);
BoxDecoration MessageBoxSenderMessage = BoxDecoration(
    color: Color.fromARGB(255, 127, 184, 223),
    borderRadius: BorderRadius.circular(10.0));
BoxDecoration MessageBoxRecieverMessage = BoxDecoration(
    color: Color.fromARGB(255, 153, 153, 153),
    borderRadius: BorderRadius.circular(10.0));

const kBackgroundColor = Color(0xFFD2FFF4);
const kPrimaryColor = Color(0xFF2D5D70);
const kSecondaryColor = Color(0xFF265DAB);

enum QuestionType { openEnded, date, multipleChoice, numberInput, yesNo }
