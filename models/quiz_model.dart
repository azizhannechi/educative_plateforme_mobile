class Quiz {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int passingScore;
  final Duration timeLimit;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.questions,
    this.passingScore = 70,
    this.timeLimit = const Duration(minutes: 30),
    required this.createdAt,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      courseId: map['courseId'],
      title: map['title'],
      description: map['description'],
      questions: (map['questions'] as List).map((q) => QuizQuestion.fromMap(q)).toList(),
      passingScore: map['passingScore'] ?? 70,
      timeLimit: Duration(minutes: map['timeLimit'] ?? 30),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'passingScore': passingScore,
      'timeLimit': timeLimit.inMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'],
      options: List<String>.from(map['options']),
      correctAnswerIndex: map['correctAnswerIndex'],
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}

class QuizResult {
  final String id;
  final String quizId;
  final String courseId;
  final String userId;
  final String userName;
  final int score;
  final int totalQuestions;
  final List<QuestionResult> answers;
  final DateTime completedAt;
  final Duration timeTaken;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.courseId,
    required this.userId,
    required this.userName,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.completedAt,
    required this.timeTaken,
  });

  double get percentage => (score / totalQuestions) * 100;
  bool get passed => percentage >= 70;

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      quizId: map['quizId'],
      courseId: map['courseId'],
      userId: map['userId'],
      userName: map['userName'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      answers: (map['answers'] as List).map((a) => QuestionResult.fromMap(a)).toList(),
      completedAt: DateTime.parse(map['completedAt']),
      timeTaken: Duration(seconds: map['timeTaken']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'courseId': courseId,
      'userId': userId,
      'userName': userName,
      'score': score,
      'totalQuestions': totalQuestions,
      'answers': answers.map((a) => a.toMap()).toList(),
      'completedAt': completedAt.toIso8601String(),
      'timeTaken': timeTaken.inSeconds,
    };
  }
}

class QuestionResult {
  final int questionIndex;
  final int selectedAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final String questionText;

  QuestionResult({
    required this.questionIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.questionText,
  });

  factory QuestionResult.fromMap(Map<String, dynamic> map) {
    return QuestionResult(
      questionIndex: map['questionIndex'],
      selectedAnswer: map['selectedAnswer'],
      correctAnswer: map['correctAnswer'],
      isCorrect: map['isCorrect'],
      questionText: map['questionText'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionIndex': questionIndex,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'questionText': questionText,
    };
  }
}