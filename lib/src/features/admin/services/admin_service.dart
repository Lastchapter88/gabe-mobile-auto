import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all bookings, optionally filtered by status
  Stream<QuerySnapshot> getAllBookingsStream({String? status}) {
    Query query = _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true);
    if (status != null && status != 'All') {
      query = query.where('status', isEqualTo: status.toLowerCase());
    }
    return query.snapshots();
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': newStatus.toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Add a task to checklist
  Future<void> addTask(String bookingId, String taskName) async {
    final tasksRef = _firestore
        .collection('jobUpdates')
        .doc(bookingId)
        .collection('tasks');
    final count = (await tasksRef.count().get()).count;

    await tasksRef.add({
      'taskName': taskName,
      'completed': false,
      'order': count,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle task completion
  Future<void> toggleTask(
    String bookingId,
    String taskId,
    bool currentStatus,
  ) async {
    await _firestore
        .collection('jobUpdates')
        .doc(bookingId)
        .collection('tasks')
        .doc(taskId)
        .update({'completed': !currentStatus});
  }
}
