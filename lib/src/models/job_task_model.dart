import 'package:cloud_firestore/cloud_firestore.dart';

class JobTask {
  final String id;
  final String jobId;
  final String taskName;
  final bool completed;
  final int order;

  JobTask({
    required this.id,
    required this.jobId,
    required this.taskName,
    required this.completed,
    required this.order,
  });

  factory JobTask.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return JobTask(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      taskName: data['taskName'] ?? '',
      completed: data['completed'] ?? false,
      order: data['order'] ?? 0,
    );
  }
}
