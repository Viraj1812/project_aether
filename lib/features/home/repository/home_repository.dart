import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_aether/services/raid_service.dart';

abstract interface class IHomeRepository {
  Future<bool> joinRaid({required String userId});

  Future<void> sendChatMessage({
    required String text,
    required String userId,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> watchChatMessages();
}

class HomeRepository implements IHomeRepository {
  HomeRepository({
    required this.firestore,
    required this.raidService,
  });

  final FirebaseFirestore firestore;
  final RaidService raidService;

  //!MARK: - Join Raid

  //
  //
  //
  //
  //
  //

  @override
  Future<bool> joinRaid({required String userId}) {
    return raidService.joinRaid(userId: userId);
  }

  //!MARK: - ============

  //
  //
  //
  //
  //
  //

  //!MARK: - Send Message

  //
  //
  //
  //
  //
  //

  @override
  Future<void> sendChatMessage({
    required String text,
    required String userId,
  }) {
    return firestore.collection('chat_messages').add(<String, dynamic>{
      'text': text,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  //!MARK: - ============

  //
  //
  //
  //
  //
  //

  //!MARK: - Watch Messages

  //
  //
  //
  //
  //
  //

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChatMessages() {
    return firestore.collection('chat_messages').orderBy('timestamp').limitToLast(25).snapshots();
  }

  //!MARK: - ============
}
