import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz_model.dart';
import '../models/course_model.dart';
import '../controllers/quiz_controller.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;
  final Course course;

  const QuizPage({super.key, required this.quiz, required this.course});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  DateTime? startTime;
  bool isSubmitted = false;
  int score = 0;
  List<QuestionResult> questionResults = [];

  final QuizController _quizController = QuizController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    selectedAnswers = List.filled(widget.quiz.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions[currentQuestionIndex];
    final totalQuestions = widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / totalQuestions,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1}/$totalQuestions',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_calculateTimeRemaining()}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Question
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (currentQuestion.explanation != null && isSubmitted)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Explication: ${currentQuestion.explanation!}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedAnswers[currentQuestionIndex] == index;
                  final isCorrect = index == currentQuestion.correctAnswerIndex;
                  bool showCorrect = isSubmitted && isCorrect;
                  bool showWrong = isSubmitted && isSelected && !isCorrect;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: showCorrect
                        ? Colors.green.withOpacity(0.2)
                        : showWrong
                        ? Colors.red.withOpacity(0.2)
                        : isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getOptionColor(
                          index,
                          isSelected,
                          showCorrect,
                          showWrong,
                        ),
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(currentQuestion.options[index]),
                      onTap: isSubmitted
                          ? null
                          : () {
                        setState(() {
                          selectedAnswers[currentQuestionIndex] = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestionIndex > 0
                      ? () {
                    setState(() {
                      currentQuestionIndex--;
                    });
                  }
                      : null,
                  child: const Text('Précédent'),
                ),

                if (currentQuestionIndex < totalQuestions - 1)
                  ElevatedButton(
                    onPressed: selectedAnswers[currentQuestionIndex] != null
                        ? () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Suivant', style: TextStyle(color: Colors.white)),
                  )
                else
                  ElevatedButton(
                    onPressed: selectedAnswers[currentQuestionIndex] != null
                        ? _submitQuiz
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Soumettre', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getOptionColor(int index, bool isSelected, bool showCorrect, bool showWrong) {
    if (showCorrect) return Colors.green;
    if (showWrong) return Colors.red;
    if (isSelected) return Colors.blue;
    return Colors.grey;
  }

  String _calculateTimeRemaining() {
    if (startTime == null) return '';
    final elapsed = DateTime.now().difference(startTime!);
    final remaining = widget.quiz.timeLimit - elapsed;

    if (remaining.isNegative) return 'Temps écoulé';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _submitQuiz() async {
    // Calculer le score
    score = 0;
    questionResults = [];

    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final question = widget.quiz.questions[i];
      final selectedAnswer = selectedAnswers[i];
      final isCorrect = selectedAnswer == question.correctAnswerIndex;

      if (isCorrect) score++;

      questionResults.add(QuestionResult(
        questionIndex: i,
        selectedAnswer: selectedAnswer ?? -1,
        correctAnswer: question.correctAnswerIndex,
        isCorrect: isCorrect,
        questionText: question.question,
      ));
    }

    // Sauvegarder le résultat
    final result = QuizResult(
      id: '${widget.quiz.id}_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}',
      quizId: widget.quiz.id,
      courseId: widget.course.id,
      userId: user!.uid,
      userName: user!.displayName ?? user!.email!.split('@')[0],
      score: score,
      totalQuestions: widget.quiz.questions.length,
      answers: questionResults,
      completedAt: DateTime.now(),
      timeTaken: DateTime.now().difference(startTime!),
    );

    await _quizController.saveQuizResult(result);

    // Afficher les résultats
    setState(() {
      isSubmitted = true;
    });

    // Montrer la boîte de dialogue des résultats
    _showResultsDialog();
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Résultats du Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: score >= widget.quiz.passingScore
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  '${((score / widget.quiz.questions.length) * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: score >= widget.quiz.passingScore ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $score/${widget.quiz.questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              score >= widget.quiz.passingScore
                  ? '✅ Félicitations ! Vous avez réussi le quiz.'
                  : '❌ Vous devez obtenir ${widget.quiz.passingScore}% pour réussir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: score >= widget.quiz.passingScore ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Temps pris: ${DateTime.now().difference(startTime!).inMinutes} minutes',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer la boîte de dialogue
            },
            child: const Text('Voir les réponses'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer la boîte de dialogue
              Navigator.pop(context, true); // Retourner à la page précédente
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}