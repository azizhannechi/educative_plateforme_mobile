import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "reviews";

  /// *************************
  /// Créer un avis
  /// *************************
  Future<void> createReview(Review review) async {
    try {
      await _firestore.collection(collection).doc(review.id).set(review.toMap());
    } catch (e) {
      print('Erreur création avis: $e');
      rethrow;
    }
  }

  /// *************************
  /// Mettre à jour un avis existant
  /// *************************
  Future<void> updateReview(String reviewId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection(collection).doc(reviewId).update(updates);
    } catch (e) {
      print('Erreur mise à jour avis: $e');
      rethrow;
    }
  }

  /// *************************
  /// Supprimer un avis
  /// *************************
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(collection).doc(reviewId).delete();
    } catch (e) {
      print('Erreur suppression avis: $e');
      rethrow;
    }
  }

  /// *************************
  /// Récupérer l'avis d'un utilisateur pour un cours spécifique
  /// *************************
  Future<Review?> getUserReview(String userId, String courseId) async {
    try {
      final query = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return Review.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      print('Erreur récupération avis utilisateur: $e');
      return null;
    }
  }

  /// *************************
  /// Stream: tous les avis d'un cours
  /// *************************
  Stream<List<Review>> listenToCourseReviews(String courseId) {
    return _firestore
        .collection(collection)
        .where('courseId', isEqualTo: courseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Review.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// *************************
  /// Stream: tous les avis d'un utilisateur
  /// *************************
  Stream<List<Review>> listenToUserReviews(String userId) {
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Review.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// *************************
  /// Récupérer tous les avis d'un cours (Future - une seule fois)
  /// *************************
  Future<List<Review>> getCourseReviews(String courseId) async {
    try {
      final query = await _firestore
          .collection(collection)
          .where('courseId', isEqualTo: courseId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Review.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erreur récupération avis cours: $e');
      return [];
    }
  }

  /// *************************
  /// Calculer la note moyenne d'un cours
  /// *************************
  Future<double> getCourseAverageRating(String courseId) async {
    try {
      final reviews = await getCourseReviews(courseId);

      if (reviews.isEmpty) return 0.0;

      int totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
      return totalRating / reviews.length;
    } catch (e) {
      print('Erreur calcul note moyenne: $e');
      return 0.0;
    }
  }

  /// *************************
  /// Compter le nombre d'avis d'un cours
  /// *************************
  Future<int> getCourseReviewsCount(String courseId) async {
    try {
      final query = await _firestore
          .collection(collection)
          .where('courseId', isEqualTo: courseId)
          .get();

      return query.docs.length;
    } catch (e) {
      print('Erreur comptage avis: $e');
      return 0;
    }
  }

  /// *************************
  /// Vérifier si un utilisateur a déjà laissé un avis pour un cours
  /// *************************
  Future<bool> hasUserReviewed(String userId, String courseId) async {
    final review = await getUserReview(userId, courseId);
    return review != null;
  }

  /// *************************
  /// Récupérer les statistiques des notes d'un cours
  /// (combien de 5 étoiles, 4 étoiles, etc.)
  /// *************************
  Future<Map<int, int>> getCourseRatingStats(String courseId) async {
    try {
      final reviews = await getCourseReviews(courseId);

      Map<int, int> stats = {
        5: 0,
        4: 0,
        3: 0,
        2: 0,
        1: 0,
      };

      for (var review in reviews) {
        stats[review.rating] = (stats[review.rating] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Erreur statistiques notes: $e');
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }
  }
}