class InternetConnectionState {
  InternetConnectionState({
    required this.isAlertShowing,
    required this.isConnected,
  });

  InternetConnectionState.initial()
      : isAlertShowing = false,
        isConnected = false;

  bool isAlertShowing;
  bool isConnected;

  InternetConnectionState copyWith({
    bool? isAlertShowing,
    bool? isConnected,
  }) {
    return InternetConnectionState(
      isAlertShowing: isAlertShowing ?? this.isAlertShowing,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
