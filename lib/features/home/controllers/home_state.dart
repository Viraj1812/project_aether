class HomeState {
  HomeState({
    required this.remainingMs,
    required this.timerActive,
    required this.isJoining,
    required this.raidStatus,
  });

  HomeState.initial();

  static const int bossDurationMs = 10 * 60 * 1000;

  int remainingMs = bossDurationMs;
  bool timerActive = true;
  bool isJoining = false;
  String raidStatus = '';

  String get formattedTime {
    final int minutes = remainingMs ~/ 60000;
    final int seconds = (remainingMs % 60000) ~/ 1000;
    final int millis = (remainingMs % 1000) ~/ 100;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '$millis';
  }

  HomeState copyWith({
    int? remainingMs,
    bool? timerActive,
    bool? isJoining,
    String? raidStatus,
  }) {
    return HomeState(
      remainingMs: remainingMs ?? this.remainingMs,
      timerActive: timerActive ?? this.timerActive,
      isJoining: isJoining ?? this.isJoining,
      raidStatus: raidStatus ?? this.raidStatus,
    );
  }
}
