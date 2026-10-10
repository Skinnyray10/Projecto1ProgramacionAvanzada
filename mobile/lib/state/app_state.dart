import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../config.dart';
import '../data/api_client.dart';
import '../data/local_db.dart';
import '../data/secure_store.dart';
import '../models/app_user.dart';
import '../models/part.dart';
import '../services/sync_service.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState({ApiClient? api, LocalDb? db, SecureStore? store, Connectivity? connectivity})
      : _api = api ?? ApiClient(),
        _db = db ?? LocalDb(),
        _store = store ?? SecureStore(),
        _connectivity = connectivity ?? Connectivity() {
    _sync = SyncService(api: _api, db: _db, store: _store);
  }

  final ApiClient _api;
  final LocalDb _db;
  final SecureStore _store;
  final Connectivity _connectivity;
  late final SyncService _sync;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _timer;

  /// Contraseña en memoria tras un login offline, para pedir el JWT al reconectar.
  String? _deferredPassword;

  StoredSession? session;
  bool? online;
  bool syncing = false;
  bool needsReauth = false;
  DateTime? lastSync;
  String? notice;

  /// Se incrementa cada vez que cambia la caché del catálogo.
  int catalogVersion = 0;

  bool get isLoggedIn => session != null;

  Future<void> init() async {
    session = await _store.readSession();
    lastSync = DateTime.tryParse(await _db.getMeta('last_sync') ?? '');

    WidgetsBinding.instance.addObserver(this);
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        online = false;
        notifyListeners();
      } else {
        sync();
      }
    });
    _timer = Timer.periodic(AppConfig.syncInterval, (_) => sync());
    unawaited(sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) sync();
  }

  Future<void> sync() async {
    if (syncing) return;
    syncing = true;
    notifyListeners();
    try {
      final report = await _sync.run(deferredPassword: _deferredPassword);
      if (report.reachedServer != null) online = report.reachedServer;

      session = await _store.readSession();
      if (session?.token != null) _deferredPassword = null;
      needsReauth = report.needsLogin && session != null;

      if (report.partsSynced != null) {
        lastSync = DateTime.now();
        catalogVersion++;
      }
      if (report.messages.isNotEmpty) notice = report.messages.join('\n');

      if (report.sessionExpired) {
        await _endSession();
        notice = 'Tu sesión expiró. Inicia sesión de nuevo.';
      } else if (report.pendingAccountRejected) {
        await _endSession();
      }
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    try {
      final auth = await _api.login(normalized, password);
      online = true;
      await _store.rememberCredentials(auth.user, password);
      await _startSession(StoredSession(user: auth.user, token: auth.token));
      unawaited(sync());
    } on ApiException catch (e) {
      if (!e.isNetwork) rethrow;
      final user = await _store.verifyOfflineCredentials(normalized, password);
      if (user == null) {
        throw const ApiException(
            'Sin conexión. Sin internet solo puedes entrar con una cuenta que ya hayas usado en este dispositivo.');
      }
      online = false;
      _deferredPassword = password;
      await _startSession(StoredSession(user: user));
      notice = 'Modo sin conexión: mostrando el catálogo guardado.';
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final name = fullName.trim();
    try {
      final auth = await _api.register(email: normalized, password: password, fullName: name);
      online = true;
      await _store.rememberCredentials(auth.user, password);
      await _startSession(StoredSession(user: auth.user, token: auth.token));
      unawaited(sync());
    } on ApiException catch (e) {
      if (!e.isNetwork) rethrow;
      final id = await _db.addPendingRegistration(normalized, name);
      await _store.savePendingPassword(id, password);
      final localUser = AppUser(id: 'pending-$id', email: normalized, fullName: name, role: 'customer');
      await _store.rememberCredentials(localUser, password);
      online = false;
      await _startSession(StoredSession(user: localUser, pendingRegistrationId: id));
      notice = 'Sin conexión: tu cuenta se creará automáticamente al recuperar internet.';
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _endSession();
    notifyListeners();
  }

  void clearNotice() => notice = null;

  Future<List<Part>> searchParts({String query = '', String? category}) =>
      _db.searchParts(query: query, category: category);

  Future<List<String>> categories() => _db.categories();

  Future<void> _startSession(StoredSession newSession) async {
    await _store.writeSession(newSession);
    session = newSession;
    needsReauth = false;
    notifyListeners();
  }

  Future<void> _endSession() async {
    _deferredPassword = null;
    needsReauth = false;
    await _store.clearSession();
    session = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
