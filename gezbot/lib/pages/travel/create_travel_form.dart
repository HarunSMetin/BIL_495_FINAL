import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/travel/travel_info.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/components/Question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelQuestionService {
  final _database_service = DatabaseService();

  Future<List<TravelQuestion>> fetchQuestions() async {
    Map<String, dynamic> jsonData =
        await _database_service.GetTravelQuestions();

    return jsonData.entries.map<TravelQuestion>((entry) {
      // Use the null-aware operator to provide a fallback for potential null values
      return TravelQuestion(
        questionId: entry.key,
        question:
            entry.value['question'] ?? 'Default Question', // Fallback if null
        answers:
            List<String>.from(entry.value['answers'] ?? []), // Fallback if null
        questionType:
            entry.value['questionType'] ?? 'Default Type', // Fallback if null
      );
    }).toList();
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

  List<TravelQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  dynamic _currentAnswer;
  QuestionType _currentQuestionType = QuestionType.date;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    var questions = await _service.fetchQuestions();

    setState(() {
      _questions = questions;
    });
  }

  void _nextQuestion() async {
    // Get the current question
    TravelQuestion currentQuestion = _questions[_currentQuestionIndex];
    dynamic firestoreAnswer = _currentAnswer;
    if (_currentAnswer is DateTime) {
      firestoreAnswer = Timestamp.fromDate(_currentAnswer);
    }
    final _auth = FirebaseAuth.instance;
    await _service._database_service.UpdateTravel(
        widget.travelId, currentQuestion.questionId, firestoreAnswer);

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentAnswer = '';
        _currentQuestionType = QuestionType.values.firstWhere((type) =>
            type.toString() ==
            'QuestionType.${_questions[_currentQuestionIndex].questionType}');
        _currentQuestionIndex++;
      });
    } else {
      _service._database_service
          .GetTravelOfUser(_auth.currentUser!.uid, widget.travelId)
          .then((travel) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TravelInformation(travel: Travel.fromMap(travel)),
          ),
        );
      });
    }
  }

  void _onAnswerChanged(String answer) {
    dynamic formattedAnswer;
    print(_currentQuestionType);
    switch (_currentQuestionType) {
      case QuestionType.date:
        formattedAnswer = DateTime.tryParse(answer);
        print("formattedAnswer: $formattedAnswer");
        break;
      case QuestionType.numberInput:
        formattedAnswer = int.tryParse(answer);
        break;
      case QuestionType.yesNo:
        formattedAnswer = answer == 'Yes';
        break;
      default:
        formattedAnswer = answer;
    }

    setState(() {
      _currentAnswer = formattedAnswer;
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
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
