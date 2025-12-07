import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "courses";

  /// *************************
  /// Create a Course
  /// *************************
  Future<void> createCourse(Course course) async {
    await _firestore.collection(collection).doc(course.id).set(course.toMap());
  }

  /// *************************
  /// Update Course
  /// *************************
  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    await _firestore.collection(collection).doc(courseId).update(updates);
  }

  /// *************************
  /// Delete Course
  /// *************************
  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection(collection).doc(courseId).delete();
  }

  /// *************************
  /// Get Course by ID
  /// *************************
  Future<Course?> getCourseById(String courseId) async {
    final doc = await _firestore.collection(collection).doc(courseId).get();
    if (!doc.exists) return null;
    return Course.fromMap(doc.data()!, doc.id);
  }

  /// *************************
  /// Stream all published courses (for students)
  /// *************************
  Stream<List<Course>> listenToPublishedCourses() {
    return _firestore
        .collection(collection)
        .where("status", isEqualTo: "published")
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList());
  }

  /// *************************
  /// Stream all courses created by admin (for admin dashboard)
  /// *************************
  Stream<List<Course>> listenToAdminCourses(String adminId) {
    return _firestore
        .collection(collection)
        .where("createdBy", isEqualTo: adminId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList());
  }

  /// *************************
  /// Add resource to a course
  /// *************************
  Future<void> addResource(String courseId, CourseResource resource) async {
    await _firestore.collection(collection).doc(courseId).update({
      "resources": FieldValue.arrayUnion([resource.toMap()])
    });
  }

  /// *************************
  /// Remove a resource from a course
  /// *************************
  Future<void> removeResource(String courseId, CourseResource resource) async {
    await _firestore.collection(collection).doc(courseId).update({
      "resources": FieldValue.arrayRemove([resource.toMap()])
    });
  }

  /// *************************
  /// Update course status (draft → pending → published)
  /// *************************
  Future<void> updateStatus(String courseId, String newStatus) async {
    await _firestore.collection(collection).doc(courseId).update({
      "status": newStatus,
    });
  }
}
