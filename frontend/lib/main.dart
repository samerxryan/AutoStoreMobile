import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: AutoPartsApp()));
}

class AutoPartsApp extends ConsumerWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AutoParts TN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light.copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: AppTheme.dark.copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).primaryTextTheme),
      ),
      themeMode: ThemeMode.system, // Supports dark mode automatically
      routerConfig: router,
    );
  }
}
