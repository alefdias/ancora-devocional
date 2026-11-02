import 'package:flutter/material.dart';

import '../router.dart';
import 'theme.dart';

class AncoraApp extends StatelessWidget {
  const AncoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Âncora: Devocional',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
