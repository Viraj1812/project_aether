// ignore_for_file: public_member_api_docs, sort_constructors_first

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:master_utility/master_utility.dart';
// Project imports:
import 'package:project_aether/constants/app_strings.dart';
import 'package:project_aether/helpers/internet_connection/internet_connection_state.dart';

final StateNotifierProvider<InternetConnetivityStateNotifier, InternetConnectionState> internetConnectionStateProvider =
    StateNotifierProvider<InternetConnetivityStateNotifier, InternetConnectionState>((Ref ref) {
  return InternetConnetivityStateNotifier()..init();
});

final FutureProvider<bool> internetConnectedProvider = FutureProvider.autoDispose<bool>((Ref ref) async {
  return InternetConnectionChecker().hasConnection;
});

class InternetConnetivityStateNotifier extends StateNotifier<InternetConnectionState> {
  InternetConnetivityStateNotifier() : super(InternetConnectionState.initial());

  final Connectivity _connectivity = Connectivity();

  void init() {
    _checkConnection();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      _checkConnectionStatus(result);
    });
  }

  Future<void> _checkConnection() async {
    try {
      final ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();
      _checkConnectionStatus(connectivityResult);
    } on PlatformException catch (e) {
      LogHelper.logError('$e');
    }
  }

  void _checkConnectionStatus(ConnectivityResult result) {
    state = state.copyWith(isConnected: result != ConnectivityResult.none);
    if (result == ConnectivityResult.none && !state.isAlertShowing) {
      _showDialogBox();
    }
  }

  void _showDialogBox() {
    return DialogHelper.showCustomAlertDialog(
      barrierDismissible: false,
      builder: (BuildContext context, Widget widget) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(AppStrings.noInternet),
            content: const Text(AppStrings.checkYourInternet),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(elevation: WidgetStateProperty.all(0)),
                onPressed: () {
                  NavigationHelper.navigatePop();
                  state = state.copyWith(isAlertShowing: false);
                  _checkConnection();
                },
                child: const Text(AppStrings.tryAgain),
              ),
            ],
          ),
        );
      },
    );
  }
}
