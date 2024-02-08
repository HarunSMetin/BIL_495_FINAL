import 'package:flutter/material.dart';
import 'package:gezbot/models/question.model.dart';

enum QuestionType {
  openEnded,
  date,
  multipleChoice,
  numberInput,
  yesNo,
  location
}

class QuestionWidget extends StatefulWidget {
  final TravelQuestion question;

  final Function(String) onAnswerChanged;

  const QuestionWidget(
      {Key? key, required this.question, required this.onAnswerChanged})
      : super(key: key);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  DateTime? selectedDate;
  String? selectedOption;
  bool yesSelected = false;
  bool noSelected = false;
  final TextEditingController _textController = TextEditingController();
  void printError(String error) {
    print('\x1B[31m$error\x1B[0m');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.question.questionType == 'date') {
      selectedDate = widget.question.userAnswer!.toDate();
    } else if (widget.question.questionType == 'multipleChoice') {
      selectedOption = widget.question.userAnswer;
    } else if (widget.question.questionType == 'yesNo') {
      yesSelected = widget.question.userAnswer == 'Yes';
      noSelected = widget.question.userAnswer == 'No';
    } else {
      _textController.text = widget.question.userAnswer ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(widget.question.question,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildAnswerField(QuestionType.values.firstWhere(
          (type) =>
              type.toString() == 'QuestionType.${widget.question.questionType}',
        )), // Handle undefined types
      ],
    );
  }

  // Builds the answer field based on the question type.
  Widget _buildAnswerField(QuestionType type) {
    switch (type) {
      case QuestionType.openEnded:
        if (widget.question.userAnswer != null) {
          return _buildTextInputField(
            type,
          );
        } else {
          return _buildTextInputField(type);
        }
      case QuestionType.numberInput:
        if (widget.question.userAnswer != null) {
          return _buildTextInputField(
            type,
          );
        } else {
          return _buildTextInputField(type);
        }
      case QuestionType.date:
        if (widget.question.userAnswer != null) {
          return _buildDateButton();
        } else {
          return _buildDateButton();
        }
      case QuestionType.multipleChoice:
        if (widget.question.userAnswer != null) {
          return _buildMultipleChoiceOptions();
        } else {
          return _buildMultipleChoiceOptions();
        }
      case QuestionType.yesNo:
        if (widget.question.userAnswer != null) {
          return _buildYesNoToggle();
        } else {
          return _buildYesNoToggle();
        }
      default:
        return Container();
    }
  }

  Widget _buildTextInputField(QuestionType type) {
    return TextField(
      controller: _textController,
      onChanged: (value) {
        widget.onAnswerChanged(value);
      },
      keyboardType: type == QuestionType.numberInput
          ? TextInputType.number
          : TextInputType.text,
    );
  }

  Widget _buildDateButton() {
    return ElevatedButton(
      onPressed: () => _selectDate(context),
      child: Text(selectedDate == null
          ? 'Select Date'
          : 'Selected Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
    );
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: widget.question.answers
          .map((option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedOption,
                onChanged: (value) => _onOptionChanged(value),
              ))
          .toList(),
    );
  }

  Widget _buildYesNoToggle() {
    return ToggleButtons(
      children: const <Widget>[Text('Yes'), Text('No')],
      isSelected: [yesSelected, noSelected],
      onPressed: (int index) => _onYesNoChanged(index),
    );
  }

  void _onOptionChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedOption = value;
        widget.onAnswerChanged(value);
      });
    }
  }

  void _onYesNoChanged(int index) {
    setState(() {
      yesSelected = index == 0;
      noSelected = index == 1;
      widget.onAnswerChanged(index == 0 ? 'Yes' : 'No'); // Notify the server
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        widget.onAnswerChanged(picked.toIso8601String());
      });
    }
  }
}
