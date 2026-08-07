import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../config/service_templates.dart';

class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> createBooking({
    required String customerName,
    required String phoneNumber,
    required String carMake,
    required String carModel,
    required int carYear,
    required String registration,
    required String serviceType,
    required String description,
    required String? licenceDiscBase64,
    required List<String> additionalImagesBase64,
    required String serviceLocation,
  }) async {
    debugPrint('📝 BookingService: Starting createBooking...');

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ BookingService: User not logged in');
      throw Exception("User not logged in");
    }
    debugPrint('✅ BookingService: User authenticated: ${user.uid}');

    // Create booking document ref (using 'jobs' collection so Admin sees it)
    final docRef = _firestore.collection('jobs').doc();
    debugPrint('📄 BookingService: Created document reference: ${docRef.id}');

    try {
      // Check if we have images
      final hasImages =
          licenceDiscBase64 != null || additionalImagesBase64.isNotEmpty;
      debugPrint(
        '🖼️ BookingService: Has images: $hasImages (licence: ${licenceDiscBase64 != null}, additional: ${additionalImagesBase64.length})',
      );

      // 0. Get checklist from Templates
      List<String> defaultChecklist = ServiceTemplates.getTemplateForType(
        serviceType,
      );

      // 1. Write the main booking details (lightweight)
      debugPrint('💾 BookingService: Writing main booking document...');
      await docRef.set({
        'bookingId': docRef.id,
        'userId': user.uid,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'carMake': carMake,
        'carModel': carModel,
        'carYear': carYear,
        'registration': registration,
        'serviceType': serviceType,
        'description': description,
        'serviceLocation': serviceLocation,
        'status': 'pending',
        'checklist': defaultChecklist,
        'completedChecklist': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'hasImages': hasImages,
      });
      debugPrint(
        '✅ BookingService: Main booking document written successfully',
      );

      // 2. Store images in a subcollection 'images' (only if we have images)
      if (hasImages) {
        debugPrint('📸 BookingService: Storing images in subcollection...');
        final imagesRef = docRef.collection('images');
        final batch = _firestore.batch();

        // Licence Disc
        if (licenceDiscBase64 != null) {
          debugPrint('📋 BookingService: Adding licence disc to batch...');
          final discRef = imagesRef.doc('licenceDisc');
          batch.set(discRef, {
            'type': 'licenceDisc',
            'base64': licenceDiscBase64,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Additional Images
        for (int i = 0; i < additionalImagesBase64.length; i++) {
          debugPrint(
            '🖼️ BookingService: Adding additional image $i to batch...',
          );
          final imgRef = imagesRef.doc(); // Auto ID
          batch.set(imgRef, {
            'type': 'additional',
            'index': i,
            'base64': additionalImagesBase64[i],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        debugPrint('💾 BookingService: Committing batch with images...');
        await batch.commit();
        debugPrint('✅ BookingService: Images batch committed successfully');
      } else {
        debugPrint(
          'ℹ️ BookingService: No images to store, skipping batch commit',
        );
      }

      debugPrint(
        '🎉 BookingService: Booking created successfully with ID: ${docRef.id}',
      );
      return docRef.id;
    } catch (e, stackTrace) {
      // If it fails, good to know why
      debugPrint('❌ BookingService: Error creating booking: $e');
      debugPrint('📚 BookingService: Stack trace: $stackTrace');

      // Try to delete the document if it was partially created
      try {
        await docRef.delete();
        debugPrint('🗑️ BookingService: Cleaned up partial booking document');
      } catch (cleanupError) {
        debugPrint(
          '⚠️ BookingService: Could not clean up document: $cleanupError',
        );
      }

      rethrow;
    }
  }
}
