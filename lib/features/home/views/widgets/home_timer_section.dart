// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_utility/master_utility.dart';
// Project imports:
import 'package:project_aether/config/assets/colors.gen.dart';
import 'package:project_aether/features/home/controllers/home_state.dart';
import 'package:project_aether/features/home/controllers/home_state_notifier.dart';

class HomeTimerSection extends ConsumerWidget {
  const HomeTimerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState homeState = ref.watch(homeStateNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          const AutoText(
            text: '🐉 World Boss Spawns In',
            style: TextStyle(color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          AutoText(
            text: homeState.formattedTime,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          if (!homeState.timerActive)
            const AutoText(
              text: '⚠️ World Boss has spawned!',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
