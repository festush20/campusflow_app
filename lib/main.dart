import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'theme.dart';

void main() => runApp(const ProviderScope(child: CampusFlowApp()));

class CampusFlowApp extends ConsumerWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair(),
      routerConfig: router,
    );
  }
}