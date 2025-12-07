import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Stream<QuerySnapshot> getAllUsers() {
    return usersCollection.orderBy('createdAt', descending: true).snapshots();
  }
}