import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/app_user.dart';

class StoredSession {
  const StoredSession({required this.user, this.token, this.pendingRegistrationId});

  final AppUser user;

  /// `null` si la sesión se abrió sin internet y aún no hay JWT del servidor.
  final String? token;

  /// Cuenta creada sin conexión que todavía no existe en el servidor.
  final int? pendingRegistrationId;

  bool get isPending => pendingRegistrationId != null;

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'token': token,
        'pendingRegistrationId': pendingRegistrationId,
      };

  factory StoredSession.fromJson(Map<String, dynamic> json) => StoredSession(
        user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
        token: json['token'] as String?,
        pendingRegistrationId: json['pendingRegistrationId'] as int?,
      );
}

/// Datos sensibles en Keychain (iOS) / Keystore (Android).
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'session';
  static const _hashRounds = 10000;

  Future<StoredSession?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null) return null;
    return StoredSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> writeSession(StoredSession session) =>
      _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));

  Future<void> clearSession() => _storage.delete(key: _sessionKey);

  /// Guarda un hash salado de la contraseña para permitir login sin internet.
  Future<void> rememberCredentials(AppUser user, String password) async {
    final salt = base64Encode(
        List<int>.generate(16, (_) => Random.secure().nextInt(256)));
    await _storage.write(
      key: _credKey(user.email),
      value: jsonEncode({
        'salt': salt,
        'hash': _hash(salt, password),
        'user': user.toJson(),
      }),
    );
  }

  /// Devuelve el usuario si la contraseña coincide con la última usada en línea.
  Future<AppUser?> verifyOfflineCredentials(String email, String password) async {
    final raw = await _storage.read(key: _credKey(email));
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (_hash(data['salt'] as String, password) != data['hash']) return null;
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> forgetCredentials(String email) =>
      _storage.delete(key: _credKey(email));

  Future<void> savePendingPassword(int registrationId, String password) =>
      _storage.write(key: 'pending_pw_$registrationId', value: password);

  Future<String?> readPendingPassword(int registrationId) =>
      _storage.read(key: 'pending_pw_$registrationId');

  Future<void> deletePendingPassword(int registrationId) =>
      _storage.delete(key: 'pending_pw_$registrationId');

  String _credKey(String email) => 'cred_${email.trim().toLowerCase()}';

  String _hash(String salt, String password) {
    List<int> digest = utf8.encode('$salt:$password');
    for (var i = 0; i < _hashRounds; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Encode(digest);
  }
}
