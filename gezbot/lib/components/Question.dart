import 'package:flutter/material.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/shared/constants.dart';

enum QuestionType { openEnded, date, multipleChoice, numberInput, yesNo }

// This widget displays a dynamic question based on the type of the question.
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
  late TextEditingController _textController;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
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
                type.toString() ==
                'QuestionType.${widget.question.questionType}',
            orElse: () => QuestionType.openEnded)), // Handle undefined types
      ],
    );
  }

  // Builds the answer field based on the question type.
  Widget _buildAnswerField(QuestionType type) {
    switch (type) {
      case QuestionType.openEnded:
      case QuestionType.numberInput:
        return _buildTextInputField(type);
      case QuestionType.date:
        return _buildDateButton();
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions();
      case QuestionType.yesNo:
        return _buildYesNoToggle();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextInputField(QuestionType type) {
    return TextField(
      controller: _textController,
      onChanged: (value) {
        setState(() {}); // Update UI on each text change
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
        selectedOption = value; // Update the state to reflect selection
      });
      widget.onAnswerChanged(value); // Continue to notify the server
    }
  }

  void _onYesNoChanged(int index) {
    setState(() {
      yesSelected = index == 0;
      noSelected = index == 1; // Update the state to reflect selection
    });
    widget.onAnswerChanged(index == 0 ? 'Yes' : 'No'); // Notify the server
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
        selectedDate = picked; // Update the state to reflect the date selection
      });
      widget.onAnswerChanged(picked.toIso8601String());
    }
  }
}
