import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchronized/synchronized.dart';

class RaidService {
  RaidService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final Lock _lock = Lock();

  Future<bool> joinRaid({required String userId}) async {
    return _lock.synchronized(() async {
      final DocumentReference<Map<String, dynamic>> raidRef = _firestore.collection('events').doc('dragon_raid');

      final DocumentSnapshot<Map<String, dynamic>> snapshot = await raidRef.get();

      final int slotsFilled = (snapshot.data()?['slots_filled'] as int?) ?? 0;
      final int maxSlots = (snapshot.data()?['max_slots'] as int?) ?? 15;

      if (slotsFilled >= maxSlots) {
        return false;
      }

      await raidRef.update(<Object, Object?>{'slots_filled': slotsFilled + 1});
      return true;
    });
  }
}
