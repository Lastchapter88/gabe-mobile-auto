import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(String jobId) {
    return _firestore
        .collection('jobs')
        .doc(jobId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
        );
  }

  Future<void> sendMessage(
    String jobId,
    String text,
    String senderId,
    String role,
  ) async {
    await _firestore.collection('jobs').doc(jobId).collection('messages').add({
      'senderId': senderId,
      'senderRole': role,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
