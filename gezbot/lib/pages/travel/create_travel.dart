import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';

class TravelQuestion {
  String questionId;
  String question;
  List<String> answers;

  TravelQuestion(
      {required this.questionId,
      required this.question,
      required this.answers});
}

class TravelQuestionService {
  final _database_service = DatabaseService();

  Future<List<TravelQuestion>> fetchQuestions() async {
    Map<String, dynamic> jsonData =
        await _database_service.GetTravelQuestions();
    return jsonData.entries.map<TravelQuestion>((entry) {
      return TravelQuestion(
        questionId: entry.key,
        question: entry.value['question'],
        answers: List<String>.from(entry.value['answers']),
      );
    }).toList();
  }
}

class QuestionWidget extends StatelessWidget {
  final TravelQuestion question;

  QuestionWidget({required Key key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(question.question),
        ...question.answers.map((answer) => Text(answer)).toList(),
        // TODO: Add logic to display different types of answers (e.g., calendar, checkboxes)
      ],
    );
  }
}

class TravelQuestionnaireForm extends StatefulWidget {
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
                      key: UniqueKey(), // Providing a unique key
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
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(isLastQuestion ? 'Create Travel' : 'Next'),
                )
              ],
            )
          : CircularProgressIndicator(),
    );
  }
}
