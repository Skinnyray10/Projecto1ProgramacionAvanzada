import '../data/api_client.dart';
import '../data/local_db.dart';
import '../data/secure_store.dart';

class SyncReport {
  /// `true` si el servidor respondió, `false` si no hubo conexión, `null` si no se intentó.
  bool? reachedServer;
  bool catalogSynced = false;
  bool sessionExpired = false;
  bool pendingAccountRejected = false;
  bool needsLogin = false;
  final List<String> messages = [];
}

/// Rutina de sincronización:
/// 1. Envía al servidor las cuentas creadas sin conexión.
/// 2. Obtiene un JWT si la sesión se abrió offline.
/// 3. Descarga piezas y autos y reemplaza la caché local.
class SyncService {
  SyncService({required this.api, required this.db, required this.store});

  final ApiClient api;
  final LocalDb db;
  final SecureStore store;

  Future<SyncReport> run({String? deferredPassword}) async {
    final report = SyncReport();
    try {
      await _flushPendingRegistrations(report);

      var session = await store.readSession();
      if (session == null || session.isPending) return report;

      if (session.token == null) {
        if (deferredPassword == null) {
          report.needsLogin = true;
          return report;
        }
        final auth = await api.login(session.user.email, deferredPassword);
        report.reachedServer = true;
        await store.rememberCredentials(auth.user, deferredPassword);
        session = StoredSession(user: auth.user, token: auth.token);
        await store.writeSession(session);
      }

      final token = session.token!;
      final parts = await api.fetchParts(token);
      report.reachedServer = true;
      final cars = await api.fetchCars(token);
      await db.replaceParts(parts);
      await db.replaceCars(cars);
      await db.setMeta('last_sync', DateTime.now().toIso8601String());
      report.catalogSynced = true;
    } on ApiException catch (e) {
      if (e.isNetwork) {
        report.reachedServer = false;
      } else {
        report.reachedServer = true;
        if (e.isUnauthorized) {
          report.sessionExpired = true;
        } else {
          report.messages.add(e.message);
        }
      }
    }
    return report;
  }

  Future<void> _flushPendingRegistrations(SyncReport report) async {
    for (final pending in await db.pendingRegistrations()) {
      final session = await store.readSession();
      final isCurrent = session?.pendingRegistrationId == pending.id;

      final password = await store.readPendingPassword(pending.id);
      if (password == null) {
        await db.markRegistrationFailed(pending.id, 'Contraseña no disponible');
        if (isCurrent) report.pendingAccountRejected = true;
        continue;
      }

      try {
        final auth = await api.register(
          email: pending.email,
          password: password,
          fullName: pending.fullName,
        );
        report.reachedServer = true;
        await store.rememberCredentials(auth.user, password);
        if (isCurrent) {
          await store.writeSession(StoredSession(user: auth.user, token: auth.token));
        }
        report.messages.add('Cuenta ${pending.email} creada en el servidor');
      } on ApiException catch (e) {
        if (e.isNetwork) rethrow;
        report.reachedServer = true;
        await db.markRegistrationFailed(pending.id, e.message);
        await store.forgetCredentials(pending.email);
        report.messages.add('No se pudo crear la cuenta ${pending.email}: ${e.message}');
        if (isCurrent) report.pendingAccountRejected = true;
        await store.deletePendingPassword(pending.id);
        continue;
      }

      await db.deletePendingRegistration(pending.id);
      await store.deletePendingPassword(pending.id);
    }
  }
}
