import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../features/booking/services/booking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/auth/auth_service.dart';

class JobProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  bool _isLoading = false;
  AuthService? _authService;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;

  List<Job> get activeJobs =>
      _jobs.where((j) => j.status != JobStatus.completed).toList();
  List<Job> get completedJobs =>
      _jobs.where((j) => j.status == JobStatus.completed).toList();

  Job? get currentJob => _jobs.isNotEmpty
      ? _jobs.firstWhere(
          (j) => j.status != JobStatus.completed,
          orElse: () => _jobs.first,
        )
      : null;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // No constructor logic needed, handled by update
  JobProvider();

  void update(AuthService auth) {
    _authService = auth;
    _listenToJobs();
  }

  void _listenToJobs() {
    final user = _authService?.user;
    if (user == null) {
      _jobs = [];
      notifyListeners();
      return;
    }

    Query query = _firestore.collection('jobs');

    final role = _authService?.role;

    if (role == 'admin') {
      // Admin sees everything
    } else if (role == 'technician') {
      // Technician sees assigned jobs
      query = query.where('technicianId', isEqualTo: user.uid);
    } else {
      // Customer sees their own jobs
      query = query.where('userId', isEqualTo: user.uid);
    }

    query.orderBy('updatedAt', descending: true).snapshots().listen((snapshot) {
      _jobs = snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> assignTechnician(
    String jobId,
    String technicianId,
    String technicianName,
  ) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'technicianId': technicianId,
      'technicianName': technicianName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addJob({
    required String customerName,
    required String phoneNumber,
    required String carMake,
    required String carModel,
    required int carYear,
    required String registration,
    required String serviceType,
    required String description,
    required String serviceLocation,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await BookingService.createBooking(
        customerName: customerName,
        phoneNumber: phoneNumber,
        carMake: carMake,
        carModel: carModel,
        carYear: carYear,
        registration: registration,
        serviceType: serviceType,
        description: description,
        serviceLocation: serviceLocation,
        licenceDiscBase64: null,
        additionalImagesBase64: [],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String jobId, JobStatus newStatus) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'status': newStatus.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleChecklistItem(String jobId, String item) async {
    final job = _jobs.firstWhere((j) => j.id == jobId);
    List<String> completed = List.from(job.completedChecklist);

    if (completed.contains(item)) {
      completed.remove(item);
    } else {
      completed.add(item);
    }

    await _firestore.collection('jobs').doc(jobId).update({
      'completedChecklist': completed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
