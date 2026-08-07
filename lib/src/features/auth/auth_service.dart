import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _role;
  bool _isLoading = false;
  bool _isApproved = false;
  String? _error;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isApproved => _isApproved;
  String? get error => _error;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserRole(user.uid);
      } else {
        _role = null;
        _isApproved = false;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;

        // Auto-fix Super Admin if needed
        if (_user?.email?.toLowerCase() == 'luckysekhula@gmail.com' &&
            data['role'] != 'admin') {
          await _firestore.collection('users').doc(uid).update({
            'role': 'admin',
            'isApproved': true,
          });
          _role = 'admin';
          _isApproved = true;
        } else {
          _role = data['role'] as String?;
          _isApproved = data['isApproved'] ?? (_role != 'technician');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  /// Signs in with Google.
  /// [targetRole] is used only if creating a NEW user.
  /// For existing users, their stored role will take precedence.
  Future<void> signInWithGoogle({String targetRole = 'customer'}) async {
    setLoading(true);
    try {
      UserCredential? credential;
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(authProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          setLoading(false);
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(cred);
      }

      if (credential.user != null) {
        await _syncUserRole(credential.user!, targetRole);
      }

      setLoading(false);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      _error = e.toString();
      setLoading(false);
      rethrow; // Propagate error to UI
    }
  }

  Future<void> _syncUserRole(User user, String targetRole) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      // New user
      String role = 'customer';
      bool isApproved = true;

      // Hardcoded Admin
      if (user.email?.toLowerCase() == 'luckysekhula@gmail.com') {
        role = 'admin';
        isApproved = true;
      }

      await userRef.set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'role': role,
        'isApproved': isApproved,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _role = role;
      _isApproved = isApproved;
    } else {
      // Existing user
      final data = doc.data()!;

      // Force Admin update if it's the super admin email
      if (user.email?.toLowerCase() == 'luckysekhula@gmail.com' &&
          data['role'] != 'admin') {
        await userRef.update({'role': 'admin', 'isApproved': true});
        _role = 'admin';
        _isApproved = true;
      } else {
        _role = data['role'] as String?;
        _isApproved = data['isApproved'] ?? (_role != 'technician');
      }

      // Fallback for null roles
      if (_role == null) {
        await userRef.update({'role': targetRole});
        _role = targetRole;
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }
}
