import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz_model.dart';

class QuizController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Stream des quiz pour un cours
  Stream<List<Quiz>> listenToCourseQuizzes(String courseId) {
    return _firestore
        .collection('quizzes')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Quiz.fromMap(doc.data())).toList();
    });
  }

  // Sauvegarder un résultat de quiz
  Future<void> saveQuizResult(QuizResult result) async {
    await _firestore.collection('quizResults').doc(result.id).set(result.toMap());
  }

  // Obtenir les résultats d'un utilisateur pour un quiz
  Stream<QuizResult?> getQuizResult(String quizId) {
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('quizResults')
        .where('quizId', isEqualTo: quizId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return QuizResult.fromMap(snapshot.docs.first.data());
    });
  }

  // Obtenir tous les résultats d'un utilisateur pour un cours
  Stream<List<QuizResult>> getUserQuizResults(String courseId) {
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('quizResults')
        .where('courseId', isEqualTo: courseId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => QuizResult.fromMap(doc.data())).toList();
    });
  }

  // Obtenir les statistiques des quiz pour un cours
  Stream<Map<String, dynamic>> getQuizStats(String courseId) {
    if (userId == null) return Stream.value({});

    return _firestore
        .collection('quizResults')
        .where('courseId', isEqualTo: courseId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final results = snapshot.docs.map((doc) => QuizResult.fromMap(doc.data())).toList();

      if (results.isEmpty) return {'averageScore': 0, 'totalQuizzes': 0, 'passedQuizzes': 0};

      double totalScore = 0;
      int passed = 0;

      for (var result in results) {
        totalScore += result.percentage;
        if (result.passed) passed++;
      }

      return {
        'averageScore': totalScore / results.length,
        'totalQuizzes': results.length,
        'passedQuizzes': passed,
        'successRate': (passed / results.length) * 100,
      };
    });
  }
}