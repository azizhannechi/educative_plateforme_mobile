import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  String id;
  String userId;
  String courseId;
  double price;
  String paymentMethod; // 'paymee' | 'card' | 'cash'
  String status; // 'pending' | 'paid' | 'failed' | 'refunded'
  String transactionId;
  DateTime createdAt;

  Purchase({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.price,
    required this.paymentMethod,
    required this.status,
    required this.transactionId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'price': price,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> data, String id) {
    return Purchase(
      id: id,
      userId: data['userId'],
      courseId: data['courseId'],
      price: (data['price'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'paymee',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}