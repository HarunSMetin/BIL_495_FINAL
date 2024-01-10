import 'package:flutter/material.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/shared/constants.dart';

import 'package:flutter/material.dart';

enum QuestionType { openEnded, date, multipleChoice, numberInput, yesNo }

class QuestionWidget extends StatefulWidget {
  final TravelQuestion question;

  QuestionWidget({Key? key, required this.question}) : super(key: key);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  DateTime? selectedDate;
  String? selectedOption;
  bool yesSelected = false;
  bool noSelected = false;

  @override
  Widget build(BuildContext context) {
    print(widget.question.questionId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(widget.question.question,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildAnswerField(QuestionType.values.firstWhere((type) =>
            type.toString() == 'QuestionType.${widget.question.questionType}')),
      ],
    );
  }

  Widget _buildAnswerField(QuestionType type) {
    switch (type) {
      case QuestionType.openEnded:
        return TextField(); // Replace with your open-ended input
      case QuestionType.date:
        return ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text(selectedDate == null
              ? 'Select Date'
              : 'Selected Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
        );
      case QuestionType.multipleChoice:
        return Column(
          children: widget.question.answers
              .map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ))
              .toList(),
        );
      case QuestionType.numberInput:
        return TextField(
          keyboardType: TextInputType.number, // For numeric input
        );
      case QuestionType.yesNo:
        return ToggleButtons(
          children: <Widget>[
            Text('Yes'),
            Text('No'),
          ],
          isSelected: [yesSelected, noSelected],
          onPressed: (int index) {
            setState(() {
              if (index == 0) {
                yesSelected = true;
                noSelected = false;
              } else {
                yesSelected = false;
                noSelected = true;
              }
            });
          },
        );
      default:
        return SizedBox.shrink(); // Empty placeholder for unmatched cases
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
