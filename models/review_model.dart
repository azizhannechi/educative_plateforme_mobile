import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String id;
  String userId;
  String courseId;
  String purchaseId;
  int rating; // 1 à 5 étoiles
  String comment;
  DateTime createdAt;
  DateTime? updatedAt; // Pour les modifications

  Review({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.purchaseId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convertir Review en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'purchaseId': purchaseId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Créer Review depuis Map Firestore
  factory Review.fromMap(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      purchaseId: data['purchaseId'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Copie avec modification
  Review copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? purchaseId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      purchaseId: purchaseId ?? this.purchaseId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}