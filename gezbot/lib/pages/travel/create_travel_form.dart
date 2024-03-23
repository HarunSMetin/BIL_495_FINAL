import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/travel/travel_info.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/components/Question.dart';

class TravelQuestionService {
  final databaseService = DatabaseService();

  Future<List<TravelQuestion>> fetchQuestions(String userID, String travelID) {
    return databaseService.getTravelQuestions(userID, travelID);
  }
}

class TravelQuestionnaireForm extends StatefulWidget {
  final String travelId;
  final String travelName;
  final String uid;
  const TravelQuestionnaireForm(
      {super.key,
      required this.travelId,
      required this.travelName,
      required this.uid});
  @override
  // ignore: library_private_types_in_public_api
  _TravelQuestionnaireFormState createState() =>
      _TravelQuestionnaireFormState();
}

class _TravelQuestionnaireFormState extends State<TravelQuestionnaireForm> {
  final TravelQuestionService _service = TravelQuestionService();
  late Travel travel;
  List<TravelQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  dynamic _currentAnswer;
  QuestionType _currentQuestionType = QuestionType.date;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadTravel() async {
    travel = await _service.databaseService.getTravelOfUser(widget.travelId);

    setState(() {
      int? parsedValue =
          int.tryParse(travel.lastUpdatedQuestionId.substring(0, 2));
      _currentQuestionIndex = parsedValue ?? 0;

      _currentQuestionType = QuestionType.values.firstWhere((type) =>
          type.toString() ==
          'QuestionType.${_questions[_currentQuestionIndex].questionType}');
    });
  }

  void _loadQuestions() async {
    var questions = await _service.fetchQuestions(widget.uid, widget.travelId);

    setState(() {
      _questions = questions;
    });
    _loadTravel();
  }

  void _nextQuestion() async {
    TravelQuestion currentQuestion = _questions[_currentQuestionIndex];
    dynamic firestoreAnswer = _currentAnswer;
    if (!currentQuestion.isUserChanged) {
      setState(() {
        _currentQuestionIndex++;
        _currentAnswer = _questions[_currentQuestionIndex].userAnswer;
        _currentAnswer ??= '';
        _currentQuestionType = QuestionType.values.firstWhere((type) =>
            type.toString() ==
            'QuestionType.${_questions[_currentQuestionIndex].questionType}');
      });
      return;
    } else {
      if (_currentAnswer != null) {
        if (_currentQuestionType == QuestionType.date) {
          firestoreAnswer = Timestamp.fromDate(_currentAnswer);
        } else if (_currentQuestionType == QuestionType.yesNo) {
          firestoreAnswer = _currentAnswer ? 'Yes' : 'No';
        } else if (_currentQuestionType == QuestionType.numberInput) {
          firestoreAnswer = _currentAnswer.toString();
        } else if (_currentQuestionType == QuestionType.multipleChoice) {
          firestoreAnswer = _currentAnswer.toString();
        } else if (_currentQuestionType == QuestionType.location) {
          firestoreAnswer = _currentAnswer.toString();
        }
      } else {
        firestoreAnswer = '';
      }
      await _service.databaseService.updateTravel(
          widget.travelId, currentQuestion.questionId, firestoreAnswer);
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentAnswer = _questions[_currentQuestionIndex].userAnswer;
        _currentAnswer ??= '';
        _currentQuestionType = QuestionType.values.firstWhere((type) =>
            type.toString() ==
            'QuestionType.${_questions[_currentQuestionIndex].questionType}');
      });
    } else {
      _service.databaseService.completeTravel(widget.travelId).then((travel) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelInformation(travel: travel),
          ),
        );
      });
    }
    var questions = await _service.fetchQuestions(widget.uid, widget.travelId);
    setState(() {
      _questions = questions;
    });
  }

  void _onAnswerChanged(String answer) {
    dynamic formattedAnswer;

    switch (_currentQuestionType) {
      case QuestionType.date:
        formattedAnswer = DateTime.tryParse(answer);
        break;
      case QuestionType.numberInput:
        formattedAnswer = int.tryParse(answer);
        break;
      case QuestionType.yesNo:
        formattedAnswer = (answer == 'Yes');
        break;
      case QuestionType.location:
        formattedAnswer = answer;
        break;
      default:
        formattedAnswer = answer;
    }

    _questions[_currentQuestionIndex].isUserChanged =
        _questions[_currentQuestionIndex].userAnswer != formattedAnswer;
    _currentAnswer = formattedAnswer;
  }

  void _previousQuestion() async {
    var questions = await _service.fetchQuestions(widget.uid, widget.travelId);

    setState(() {
      _questions = questions;
    });
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _currentQuestionType = QuestionType.values.firstWhere((type) =>
            type.toString() ==
            'QuestionType.${_questions[_currentQuestionIndex].questionType}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.travelName)),
      body: _questions.isNotEmpty
          ? Column(
              children: <Widget>[
                Expanded(
                  child: QuestionWidget(
                    key: UniqueKey(),
                    question: _questions[_currentQuestionIndex],
                    onAnswerChanged: _onAnswerChanged,
                  ),
                ),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                      '${_currentQuestionIndex + 1} of ${_questions.length} questions'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_currentQuestionIndex > 0)
                      ElevatedButton(
                        onPressed: _previousQuestion,
                        child: const Text('Back'),
                      ),
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      child: Text(isLastQuestion ? 'Create Travel' : 'Next'),
                    ),
                  ],
                ),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
