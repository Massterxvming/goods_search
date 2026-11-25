import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/repositories/backend_repository.dart';
import '../../../../data/repositories/market_price_repository.dart';
import '../../../../data/services/serverpod_service.dart';
import '../../home/views/home_page.dart';
import '../../profile/views/profile_page.dart';
import '../view_models/service_status_view_model.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.backendRepository,
    this.marketPriceRepository,
  });
  final BackendRepository? backendRepository;
  final MarketPriceRepository? marketPriceRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ServiceStatusViewModel _serviceStatus;
  late final MarketPriceRepository _marketPriceRepository;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _serviceStatus = ServiceStatusViewModel(
      widget.backendRepository ??
          ServerpodBackendRepository(ServerpodService()),
    );
    unawaited(_serviceStatus.refresh());
    _marketPriceRepository =
        widget.marketPriceRepository ??
        ServerpodMarketPriceRepository(ServerpodService());
  }

  @override
  void dispose() {
    _serviceStatus.dispose();
    _marketPriceRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _serviceStatus,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child: IndexedStack(
              index: _selectedTab,
              children: [
                HomePage(
                  status: _serviceStatus.status,
                  repository: _marketPriceRepository,
                ),
                ProfilePage(
                  status: _serviceStatus.status,
                  onRefresh: () => unawaited(_serviceStatus.refresh()),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8EDE7))),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) =>
                  setState(() => _selectedTab = index),
              destinations: const [
                NavigationDestination(
                  key: Key('tab-home'),
                  icon: Icon(Icons.grid_view_outlined, size: 23),
                  selectedIcon: Icon(Icons.grid_view_rounded, size: 23),
                  label: '首页',
                ),
                NavigationDestination(
                  key: Key('tab-profile'),
                  icon: Icon(Icons.person_outline_rounded, size: 25),
                  selectedIcon: Icon(Icons.person_rounded, size: 25),
                  label: '我的',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
