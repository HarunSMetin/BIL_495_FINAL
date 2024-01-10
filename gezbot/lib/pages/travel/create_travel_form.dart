import 'package:flutter/material.dart';
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

  const TravelQuestionnaireForm({super.key, required this.travelId});
  @override
  _TravelQuestionnaireFormState createState() =>
      _TravelQuestionnaireFormState();
}

class _TravelQuestionnaireFormState extends State<TravelQuestionnaireForm> {
  final TravelQuestionService _service = TravelQuestionService();
  List<TravelQuestion> _questions = [];
  int _currentQuestionIndex = 0;

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

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      //TODO: Handle 'Create Travel' action
    }
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
      appBar: AppBar(title: Text('Travel Questionnaire')),
      body: _questions.isNotEmpty
          ? Column(
              children: <Widget>[
                Expanded(
                  child: QuestionWidget(
                      key: UniqueKey(),
                      question: _questions[_currentQuestionIndex]),
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
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // This will space out the buttons evenly
                  children: [
                    // Only show the Back button if not on the first question
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
