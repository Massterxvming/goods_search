import 'package:flutter/material.dart';

import 'data/repositories/backend_repository.dart';
import 'data/repositories/market_price_repository.dart';
import 'ui/features/shell/views/app_shell.dart';

class GoodsSearchApp extends StatelessWidget {
  const GoodsSearchApp({
    super.key,
    this.backendRepository,
    this.marketPriceRepository,
  });

  final BackendRepository? backendRepository;
  final MarketPriceRepository? marketPriceRepository;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF203D34);
    return MaterialApp(
      title: '价迹 · 看见价格的变化',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          primary: ink,
          surface: const Color(0xFFF7F9F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F6),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F6),
          foregroundColor: ink,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 74,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFFE7EFE7),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: states.contains(WidgetState.selected)
                  ? ink
                  : const Color(0xFF87918A),
            ),
          ),
        ),
      ),
      home: AppShell(
        backendRepository: backendRepository,
        marketPriceRepository: marketPriceRepository,
      ),
    );
  }
}
