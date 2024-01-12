class TravelQuestion {
  String questionId;
  String question;
  List<String> answers;
  String questionType;
  dynamic userAnswer;
  bool isUserChanged = false;

  TravelQuestion(
      {required this.questionId,
      required this.question,
      required this.answers,
      required this.questionType,
      this.userAnswer,
      this.isUserChanged = false});

  factory TravelQuestion.fromMap(Map<String, dynamic> map) {
    return TravelQuestion(
        questionId: map['questionId'],
        question: map['question'],
        answers: List<String>.from(map['answers']),
        questionType: map['questionType'],
        userAnswer: map['userAnswer']);
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'question': question,
      'answers': answers,
      'questionType': questionType,
      'userAnswer': userAnswer,
      'isUserChanged': isUserChanged,
    };
  }
}
