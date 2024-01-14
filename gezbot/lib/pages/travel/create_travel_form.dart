import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/travel/travel_info.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/components/Question.dart';

class TravelQuestionService {
  final _database_service = DatabaseService();

  Future<List<TravelQuestion>> fetchQuestions() {
    return _database_service.GetTravelQuestions();
  }
}

class TravelQuestionnaireForm extends StatefulWidget {
  final String travelId;
  final String travelName;

  const TravelQuestionnaireForm(
      {super.key, required this.travelId, required this.travelName});
  @override
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
    travel = await _service._database_service.GetTravelOfUser(widget.travelId);
    setState(() {
      int? parsedValue =
          int.tryParse(travel.lastUpdatedQuestionId.substring(0, 2));
      _currentQuestionIndex = parsedValue ?? 0;

      _currentQuestionType = QuestionType.values.firstWhere((type) =>
          type.toString() ==
          'QuestionType.${_questions[_currentQuestionIndex].questionType}');
    });
    for (TravelQuestion question in _questions) {
      dynamic answer = travel.fieldFromQuestionId(question.questionId);
      if (answer != '') {
        question.userAnswer = answer;
        break;
      }
    }
  }

  void _loadQuestions() async {
    var questions = await _service.fetchQuestions();
    setState(() {
      _questions = questions;
    });
    _loadTravel();
  }

  void _nextQuestion() async {
    TravelQuestion currentQuestion = _questions[_currentQuestionIndex];
    dynamic firestoreAnswer = _currentAnswer;
    if (!currentQuestion.isUserChanged) {
    } else {
      if (_currentQuestionType == QuestionType.date) {
        firestoreAnswer = Timestamp.fromDate(_currentAnswer);
      } else if (_currentQuestionType == QuestionType.yesNo) {
        firestoreAnswer = _currentAnswer ? 'Yes' : 'No';
      } else if (_currentQuestionType == QuestionType.numberInput) {
        firestoreAnswer = _currentAnswer.toString();
      } else if (_currentQuestionType == QuestionType.multipleChoice) {
        firestoreAnswer = _currentAnswer.toString();
      }
      await _service._database_service.UpdateTravel(
          widget.travelId, currentQuestion.questionId, firestoreAnswer);
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentAnswer = travel
            .fieldFromQuestionId(_questions[_currentQuestionIndex].questionId);
        _currentAnswer ??= '';
        _currentQuestionType = QuestionType.values.firstWhere((type) =>
            type.toString() ==
            'QuestionType.${_questions[_currentQuestionIndex].questionType}');
      });
    } else {
      _service._database_service.CompleteTravel(widget.travelId).then((travel) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelInfo(travel: travel),
          ),
        );
      });
    }
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
      default:
        formattedAnswer = answer;
    }

    _questions[_currentQuestionIndex].isUserChanged = true;
    _currentAnswer = formattedAnswer;
  }

  void _previousQuestion() {
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
      appBar: AppBar(title: Text('${widget.travelName}')),
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
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                      '${_currentQuestionIndex + 1} of ${_questions.length} questions'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_currentQuestionIndex > 0)
                      ElevatedButton(
                        onPressed: _previousQuestion,
                        child: Text('Back'),
                      ),
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      child: Text(isLastQuestion ? 'Create Travel' : 'Next'),
                    ),
                  ],
                ),
              ],
            )
          : CircularProgressIndicator(),
    );
  }
}
