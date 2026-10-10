import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../widgets/sync_status_bar.dart';
import 'cars_screen.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});

  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    state.addListener(_showNotice);
    _showNotice();
  }

  @override
  void dispose() {
    state.removeListener(_showNotice);
    super.dispose();
  }

  void _showNotice() {
    final notice = state.notice;
    if (notice == null) return;
    state.clearNotice();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notice)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = state.session?.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'PIEZAS' : 'AUTOS',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            onPressed: state.syncing ? null : state.sync,
            icon: const Icon(Icons.sync),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (_) => state.logout(),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text('${user?.fullName ?? ''}\n${user?.email ?? ''}'),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SyncStatusBar(state: state),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                ProductsScreen(state: state),
                CarsScreen(state: state),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Piezas'),
          NavigationDestination(icon: Icon(Icons.directions_car_outlined), label: 'Autos'),
        ],
      ),
    );
  }
}
