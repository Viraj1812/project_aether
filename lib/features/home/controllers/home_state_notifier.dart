import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:project_aether/features/home/controllers/home_state.dart';
import 'package:project_aether/features/home/repository/home_repository.dart';
import 'package:project_aether/services/raid_service.dart';

const String _defaultUserId = 'user_123';

final Provider<IHomeRepository> homeRepositoryProvider = Provider<IHomeRepository>((Ref ref) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  return HomeRepository(
    firestore: firestore,
    raidService: RaidService(firestore: firestore),
  );
});

final StreamProvider<QuerySnapshot<Map<String, dynamic>>> homeChatMessagesProvider =
    StreamProvider<QuerySnapshot<Map<String, dynamic>>>((Ref ref) {
  return ref.watch(homeRepositoryProvider).watchChatMessages();
});

final StateNotifierProvider<HomeStateNotifier, HomeState> homeStateNotifierProvider =
    StateNotifierProvider<HomeStateNotifier, HomeState>((Ref ref) {
  final HomeStateNotifier notifier = HomeStateNotifier(
    homeRepository: ref.read(homeRepositoryProvider),
  )..startTimer();
  ref.onDispose(notifier.disposeTimer);
  return notifier;
});

class HomeStateNotifier extends StateNotifier<HomeState> {
  HomeStateNotifier({
    required this.homeRepository,
  }) : super(HomeState.initial());

  final IHomeRepository homeRepository;

  bool _timerCancelled = false;

  //!MARK: - Start Timer

  void startTimer() {
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_timerCancelled || !state.timerActive) return false;

      if (state.remainingMs > 0) {
        state = state.copyWith(remainingMs: state.remainingMs - 100);
      } else {
        state = state.copyWith(timerActive: false);
      }
      return state.timerActive;
    });
  }

  //!MARK: - Dispose Timer

  void disposeTimer() {
    _timerCancelled = true;
  }

  //
  //
  //

  //!MARK: - Join Raid

  Future<void> joinRaid() async {
    state = state.copyWith(isJoining: true, raidStatus: '');

    final bool success = await homeRepository.joinRaid(userId: _defaultUserId);

    state = state.copyWith(
      isJoining: false,
      raidStatus: success ? '⚔️ You joined the raid!' : '❌ Raid is full. Try next time.',
    );
  }

  //!MARK: - Send Message

  Future<void> sendChatMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await homeRepository.sendChatMessage(
      text: trimmed,
      userId: _defaultUserId,
    );
  }
}
