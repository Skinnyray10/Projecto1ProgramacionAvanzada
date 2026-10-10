import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/part.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import '../widgets/stock_badge.dart';
import '../widgets/sync_status_bar.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.state});

  final AppState state;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Part> _parts = [];
  List<String> _categories = [];
  String? _category;
  bool _loading = true;
  int _loadedVersion = -1;

  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChanged);
    _onStateChanged();
  }

  @override
  void dispose() {
    state.removeListener(_onStateChanged);
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (state.catalogVersion != _loadedVersion) {
      _loadedVersion = state.catalogVersion;
      _load();
    }
    final notice = state.notice;
    if (notice != null) {
      state.clearNotice();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notice)));
        }
      });
    }
  }

  Future<void> _load() async {
    final results = await Future.wait([
      state.searchParts(query: _search.text, category: _category),
      state.categories(),
    ]);
    if (!mounted) return;
    setState(() {
      _parts = results[0] as List<Part>;
      _categories = results[1] as List<String>;
      if (_category != null && !_categories.contains(_category)) _category = null;
      _loading = false;
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _load);
  }

  @override
  Widget build(BuildContext context) {
    final user = state.session?.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CATÁLOGO', style: TextStyle(fontWeight: FontWeight.w900)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, SKU, marca…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final c in [null, ..._categories])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c ?? 'Todas'),
                        selected: _category == c,
                        onSelected: (_) {
                          setState(() => _category = c);
                          _load();
                        },
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              color: AzColors.red,
              onRefresh: state.sync,
              child: _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_parts.isEmpty) {
      final emptyCatalog = _search.text.isEmpty && _category == null;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(emptyCatalog ? Icons.cloud_download_outlined : Icons.search_off,
              size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            emptyCatalog
                ? 'No hay productos guardados.\nConéctate a internet y desliza para sincronizar.'
                : 'Sin resultados para tu búsqueda.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _parts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _PartTile(part: _parts[i]),
    );
  }
}

class _PartTile extends StatelessWidget {
  const _PartTile({required this.part});

  final Part part;

  @override
  Widget build(BuildContext context) {
    final subtitle = [part.sku, if (part.brand != null) part.brand!].join(' · ');
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailScreen(part: part))),
        child: Container(
          decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AzColors.orange, width: 4))),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(part.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    StockBadge(stock: part.stock),
                  ],
                ),
              ),
              Text(formatPrice(part.unitPrice),
                  style: const TextStyle(
                      color: AzColors.red, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
