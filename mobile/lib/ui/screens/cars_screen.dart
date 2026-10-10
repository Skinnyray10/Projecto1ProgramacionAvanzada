import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/car.dart';
import '../../state/app_state.dart';
import '../theme.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key, required this.state});

  final AppState state;

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Car> _cars = [];
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
  }

  Future<void> _load() async {
    final cars = await state.searchCars(query: _search.text);
    if (!mounted) return;
    setState(() {
      _cars = cars;
      _loading = false;
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _load);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar por marca, modelo, año…',
              prefixIcon: Icon(Icons.search),
            ),
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
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_cars.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.directions_car_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            _search.text.isEmpty
                ? 'No hay autos guardados.\nConéctate a internet y desliza para sincronizar.'
                : 'Sin resultados para tu búsqueda.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _cars.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _CarTile(car: _cars[i]),
    );
  }
}

class _CarTile extends StatelessWidget {
  const _CarTile({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${car.year}',
      if (car.color != null) car.color!,
      if (car.plates != null) 'Placas ${car.plates}',
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Container(
          decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AzColors.orange, width: 4))),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.directions_car, color: AzColors.red, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final rows = <(String, String?)>[
      ('Marca', car.brand),
      ('Modelo', car.model),
      ('Año', '${car.year}'),
      ('Color', car.color),
      ('Placas', car.plates),
      ('VIN', car.vin),
      ('Dueño', car.ownerName),
      ('Notas', car.notes),
    ].where((r) => r.$2 != null);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(car.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text(label,
                              style: const TextStyle(fontWeight: FontWeight.w700))),
                      Expanded(child: Text(value!)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
