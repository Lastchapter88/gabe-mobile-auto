import 'package:cloud_firestore/cloud_firestore.dart';

enum JobStatus { pending, quoteSent, inProgress, ready, completed }

class Job {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String carMake;
  final String carModel;
  final int? carYear;
  final String registration;
  final String serviceType;
  final String description;
  final JobStatus status;
  final List<String> checklist;
  final List<String> completedChecklist;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;
  final String? technicianId;
  final String? technicianName;
  final String serviceLocation; // 'Mobile' or 'Workshop'

  Job({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.carMake,
    required this.carModel,
    this.carYear,
    required this.registration,
    required this.serviceType,
    required this.description,
    required this.status,
    this.checklist = const [],
    this.completedChecklist = const [],
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.technicianId,
    this.technicianName,
    this.serviceLocation = 'Mobile',
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      carMake: data['carMake'] ?? '',
      carModel: data['carModel'] ?? '',
      carYear: data['carYear'] as int?,
      registration: data['registration'] ?? '',
      serviceType: data['serviceType'] ?? '',
      description: data['description'] ?? '',
      status: JobStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => JobStatus.pending,
      ),
      checklist: List<String>.from(data['checklist'] ?? []),
      completedChecklist: List<String>.from(data['completedChecklist'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'],
      technicianId: data['technicianId'],
      technicianName: data['technicianName'],
      serviceLocation: data['serviceLocation'] ?? 'Mobile',
    );
  }
}
