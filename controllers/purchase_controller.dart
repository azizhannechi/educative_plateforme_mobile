import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/purchase_model.dart';

class PurchaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "purchases";

  /// *************************
  /// Create purchase (before payment)
  /// status = pending
  /// *************************
  Future<String> createPurchase(Purchase purchase) async {
    try {
      await _firestore.collection(collection).doc(purchase.id).set(purchase.toMap());
      return purchase.id;
    } catch (e) {
      print("Erreur création purchase: $e");
      return "";
    }
  }

  /// *************************
  /// Update purchase after payment callback
  /// *************************
  Future<void> updateStatus(String purchaseId, String status,
      {String? transactionId}) async {
    await _firestore.collection(collection).doc(purchaseId).update({
      'status': status,
      if (transactionId != null) 'transactionId': transactionId,
    });
  }

  /// *************************
  /// Get purchase by user + course
  /// (To check if user already paid)
  /// *************************
  Future<Purchase?> getUserPurchase(String userId, String courseId) async {
    final query = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return Purchase.fromMap(query.docs.first.data(), query.docs.first.id);
  }

  /// *************************
  /// Check if user already owns course
  /// *************************
  Future<bool> userOwnsCourse(String userId, String courseId) async {
    final purchase = await getUserPurchase(userId, courseId);
    return purchase?.status == "paid";
  }

  /// *************************
  /// Stream: user purchases (for My Courses screen)
  /// *************************
  Stream<List<Purchase>> listenToUserPurchases(String userId) {
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: "paid")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Purchase.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// *************************
  /// Stream: purchases of a course (for admin)
  /// *************************
  Stream<List<Purchase>> listenToCoursePurchases(String courseId) {
    return _firestore
        .collection(collection)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Purchase.fromMap(doc.data(), doc.id))
        .toList());
  }
}
