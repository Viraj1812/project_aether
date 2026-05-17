// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_utility/master_utility.dart';
// Project imports:
import 'package:project_aether/config/assets/colors.gen.dart';
import 'package:project_aether/features/home/controllers/home_state.dart';
import 'package:project_aether/features/home/controllers/home_state_notifier.dart';

class HomeRaidSection extends ConsumerWidget {
  const HomeRaidSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState homeState = ref.watch(homeStateNotifierProvider);
    final HomeStateNotifier notifier = ref.read(homeStateNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AutoText(
            text: "⚔️ Geo-Raid: Dragon's Lair",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const AutoText(
            text: '15 slots available — first come, first served',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: homeState.isJoining ? null : notifier.joinRaid,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: homeState.isJoining
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const AutoText(
                    text: 'Join Raid',
                    style: TextStyle(color: AppColors.white),
                  ),
          ),
          if (homeState.raidStatus.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            AutoText(
              text: homeState.raidStatus,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
