// Flutter imports:
// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_utility/master_utility.dart';
// Project imports:
import 'package:project_aether/config/assets/colors.gen.dart';
import 'package:project_aether/features/home/views/widgets/home_chat_section.dart';
import 'package:project_aether/features/home/views/widgets/home_raid_section.dart';
import 'package:project_aether/features/home/views/widgets/home_timer_section.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const AutoText(
          text: 'Project Aether',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            HomeTimerSection(),
            SizedBox(height: 20),
            HomeRaidSection(),
            SizedBox(height: 20),
            Expanded(child: HomeChatSection()),
          ],
        ),
      ),
    );
  }
}
