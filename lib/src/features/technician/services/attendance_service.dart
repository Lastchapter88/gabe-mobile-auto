import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Handles technician clock-in/clock-out, each shift tagged with a GPS
/// location, so admins/HR can see when and where a clocking was made.
///
/// Firestore shape (`attendance` collection) — this is the same collection
/// and `status` values already read by the admin's Timesheets tab
/// (manage_technicians_screen.dart), so clocking out here is what populates
/// that approval queue:
///   userId, userName, clockIn (Timestamp), clockInLocation (GeoPoint),
///   clockOut (Timestamp?), clockOutLocation (GeoPoint?),
///   durationMinutes (int?), status ('active' | 'pending_approval' | 'approved' | 'rejected')
class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('attendance');

  /// The technician's currently open shift (clocked in, not yet clocked
  /// out), if any. A technician should only ever have zero or one of these.
  static Stream<QuerySnapshot<Map<String, dynamic>>> activeShiftStream(
    String userId,
  ) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots();
  }

  /// This technician's shift history, most recent first.
  static Stream<QuerySnapshot<Map<String, dynamic>>> myShiftsStream(
    String userId, {
    int limit = 30,
  }) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('clockIn', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Resolves the device's current GPS position, requesting permission and
  /// checking that location services are on first. Throws a plain
  /// [Exception] with a user-facing message on failure.
  static Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception(
        'Location services are turned off. Enable GPS to clock in/out.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission denied. Allow location access to clock in/out.',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Enable it from your device settings to clock in/out.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Starts a new shift, capturing the technician's current location.
  static Future<void> clockIn({
    required String userId,
    required String userName,
  }) async {
    final position = await getCurrentPosition();

    await _collection.add({
      'userId': userId,
      'userName': userName,
      'clockIn': FieldValue.serverTimestamp(),
      'clockInLocation': GeoPoint(position.latitude, position.longitude),
      'clockOut': null,
      'clockOutLocation': null,
      'durationMinutes': null,
      'status': 'active',
    });
  }

  /// Ends an open shift, capturing the technician's current location and
  /// the shift duration, and moves it into the admin approval queue.
  static Future<void> clockOut({
    required String shiftId,
    required DateTime clockInTime,
  }) async {
    final position = await getCurrentPosition();
    final durationMinutes = DateTime.now().difference(clockInTime).inMinutes;

    await _collection.doc(shiftId).update({
      'clockOut': FieldValue.serverTimestamp(),
      'clockOutLocation': GeoPoint(position.latitude, position.longitude),
      'durationMinutes': durationMinutes < 0 ? 0 : durationMinutes,
      'status': 'pending_approval',
    });
  }
}
