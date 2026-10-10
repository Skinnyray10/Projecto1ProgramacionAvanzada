import 'dart:convert';

import 'package:geolocator/geolocator.dart';

import '../data/api_client.dart';
import '../data/local_db.dart';
import '../data/secure_store.dart';

enum LocationStatus { unknown, active, disabled, denied }

/// Lee el GPS y envía la última posición al servidor.
/// Sin conexión, la posición queda guardada y se envía en el siguiente intento.
class LocationService {
  LocationService({required this.api, required this.db, required this.store});

  final ApiClient api;
  final LocalDb db;
  final SecureStore store;

  static const _pendingKey = 'pending_location';

  Future<LocationStatus> capture() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationStatus.disabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return LocationStatus.denied;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    await db.setMeta(
      _pendingKey,
      jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'recordedAt': position.timestamp.toUtc().toIso8601String(),
      }),
    );
    await flush();
    return LocationStatus.active;
  }

  Future<void> flush() async {
    final raw = await db.getMeta(_pendingKey);
    final token = (await store.readSession())?.token;
    if (raw == null || token == null) return;

    try {
      await api.sendLocation(token, jsonDecode(raw) as Map<String, dynamic>);
      await db.deleteMeta(_pendingKey);
    } on ApiException catch (e) {
      if (!e.isNetwork) await db.deleteMeta(_pendingKey);
    }
  }
}
