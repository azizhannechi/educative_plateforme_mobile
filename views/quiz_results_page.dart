import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizResultsPage extends StatelessWidget {
  final QuizResult result;
  final Quiz quiz;

  const QuizResultsPage({super.key, required this.result, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails des résultats'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête
          Card(
            color: result.passed ? Colors.green[50] : Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    result.passed ? '✅ Quiz Réussi' : '❌ Quiz Échoué',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: result.passed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: ${result.score}/${result.totalQuestions} (${result.percentage.toStringAsFixed(1)}%)',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complété le: ${result.completedAt.day}/${result.completedAt.month}/${result.completedAt.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Temps pris: ${result.timeTaken.inMinutes} minutes',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Détails des questions
          const Text(
            'Réponses détaillées:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...result.answers.asMap().entries.map((entry) {
            final index = entry.key;
            final answer = entry.value;
            final question = quiz.questions[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}: ${answer.questionText}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Options
                    ...question.options.asMap().entries.map((optionEntry) {
                      final optIndex = optionEntry.key;
                      final option = optionEntry.value;

                      bool isSelected = answer.selectedAnswer == optIndex;
                      bool isCorrect = question.correctAnswerIndex == optIndex;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : isSelected
                              ? Colors.red.withOpacity(0.2)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isCorrect
                                ? Colors.green
                                : isSelected
                                ? Colors.red
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCorrect
                                    ? Colors.green
                                    : isSelected
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + optIndex),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(option)),
                            if (isSelected && isCorrect)
                              const Icon(Icons.check, color: Colors.green),
                            if (isSelected && !isCorrect)
                              const Icon(Icons.close, color: Colors.red),
                            if (isCorrect && !isSelected)
                              const Icon(Icons.star, color: Colors.green),
                          ],
                        ),
                      );
                    }).toList(),

                    if (question.explanation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '💡 ${question.explanation!}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}