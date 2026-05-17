// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:master_utility/master_utility.dart';

final FutureProviderFamily<void, BuildContext> splashScreenFutureProvider =
    FutureProvider.autoDispose.family<void, BuildContext>((Ref ref, BuildContext context) async {
  SizeHelper.setMediaQuerySize(context: context);
  await Future<void>.delayed(const Duration(seconds: 3), () async {});
});
