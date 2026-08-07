import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Utility class to test Firestore connectivity and permissions
class FirestoreTestUtil {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Test basic Firestore connectivity
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};

    debugPrint('🔍 Starting Firestore diagnostics...');

    // 1. Check authentication
    final user = _auth.currentUser;
    results['authenticated'] = user != null;
    results['userId'] = user?.uid;
    debugPrint('👤 User authenticated: ${user != null} (${user?.uid ?? "N/A"})');

    // 2. Test read permissions on jobs collection
    try {
      debugPrint('📖 Testing read access to jobs collection...');
      final snapshot = await _firestore
          .collection('jobs')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      results['canReadJobs'] = true;
      results['jobsCount'] = snapshot.docs.length;
      debugPrint('✅ Can read jobs collection (${snapshot.docs.length} docs)');
    } catch (e) {
      results['canReadJobs'] = false;
      results['readError'] = e.toString();
      debugPrint('❌ Cannot read jobs collection: $e');
    }

    // 3. Test write permissions on jobs collection
    if (user != null) {
      try {
        debugPrint('✍️ Testing write access to jobs collection...');
        final testDocRef = _firestore.collection('jobs').doc();
        await testDocRef
            .set({
              'test': true,
              'userId': user.uid,
              'timestamp': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 10));

        results['canWriteJobs'] = true;
        debugPrint('✅ Can write to jobs collection');

        // Clean up test document
        await testDocRef.delete();
        debugPrint('🗑️ Cleaned up test document');
      } catch (e) {
        results['canWriteJobs'] = false;
        results['writeError'] = e.toString();
        debugPrint('❌ Cannot write to jobs collection: $e');
      }

      // 4. Test subcollection write (for images)
      try {
        debugPrint('🖼️ Testing subcollection write access...');
        final testDocRef = _firestore.collection('jobs').doc();
        await testDocRef.set({
          'test': true,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        final imageRef = testDocRef.collection('images').doc('test');
        await imageRef
            .set({'test': true, 'timestamp': FieldValue.serverTimestamp()})
            .timeout(const Duration(seconds: 10));

        results['canWriteSubcollection'] = true;
        debugPrint('✅ Can write to subcollections');

        // Clean up
        await imageRef.delete();
        await testDocRef.delete();
        debugPrint('🗑️ Cleaned up test documents');
      } catch (e) {
        results['canWriteSubcollection'] = false;
        results['subcollectionError'] = e.toString();
        debugPrint('❌ Cannot write to subcollections: $e');
      }
    } else {
      results['canWriteJobs'] = false;
      results['writeError'] = 'User not authenticated';
      debugPrint('⚠️ Skipping write tests - user not authenticated');
    }

    // 5. Test network connectivity
    try {
      debugPrint('🌐 Testing network connectivity...');
      await _firestore
          .collection('jobs')
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      results['networkConnected'] = true;
      debugPrint('✅ Network connected to Firestore');
    } catch (e) {
      results['networkConnected'] = false;
      results['networkError'] = e.toString();
      debugPrint('❌ Network issue: $e');
    }

    debugPrint('🏁 Diagnostics complete');
    return results;
  }

  /// Print a formatted report of the test results
  static void printReport(Map<String, dynamic> results) {
    debugPrint('\n${'=' * 50}');
    debugPrint('FIRESTORE DIAGNOSTICS REPORT');
    debugPrint('=' * 50);

    debugPrint('\n📊 Authentication:');
    debugPrint('  Authenticated: ${results['authenticated']}');
    debugPrint('  User ID: ${results['userId'] ?? "N/A"}');

    debugPrint('\n📖 Read Permissions:');
    debugPrint('  Can read jobs: ${results['canReadJobs']}');
    if (results['canReadJobs'] == false) {
      debugPrint('  Error: ${results['readError']}');
    }

    debugPrint('\n✍️ Write Permissions:');
    debugPrint('  Can write jobs: ${results['canWriteJobs']}');
    if (results['canWriteJobs'] == false) {
      debugPrint('  Error: ${results['writeError']}');
    }

    debugPrint('\n🖼️ Subcollection Permissions:');
    debugPrint('  Can write subcollections: ${results['canWriteSubcollection']}');
    if (results['canWriteSubcollection'] == false) {
      debugPrint('  Error: ${results['subcollectionError']}');
    }

    debugPrint('\n🌐 Network:');
    debugPrint('  Connected: ${results['networkConnected']}');
    if (results['networkConnected'] == false) {
      debugPrint('  Error: ${results['networkError']}');
    }

    debugPrint('\n${'=' * 50}');

    // Summary
    final allGood =
        results['authenticated'] == true &&
        results['canReadJobs'] == true &&
        results['canWriteJobs'] == true &&
        results['canWriteSubcollection'] == true &&
        results['networkConnected'] == true;

    if (allGood) {
      debugPrint('✅ ALL TESTS PASSED - Firestore is configured correctly');
    } else {
      debugPrint('❌ SOME TESTS FAILED - Please review the errors above');
    }
    debugPrint('=' * 50 + '\n');
  }
}
