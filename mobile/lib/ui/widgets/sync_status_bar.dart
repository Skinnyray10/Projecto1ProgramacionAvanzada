import 'package:flutter/material.dart';

import '../../services/location_service.dart';
import '../../state/app_state.dart';
import '../theme.dart';

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final (color, icon, text) = _status();
    return Material(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: const TextStyle(color: Colors.white, fontSize: 13))),
            Icon(
              state.locationStatus == LocationStatus.active
                  ? Icons.location_on
                  : Icons.location_off,
              size: 18,
              color: Colors.white,
              semanticLabel: state.locationStatus == LocationStatus.active
                  ? 'Ubicación compartida'
                  : 'Ubicación no compartida',
            ),
            if (state.needsReauth)
              TextButton(
                onPressed: state.logout,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('INGRESAR'),
              ),
          ],
        ),
      ),
    );
  }

  (Color, IconData, String) _status() {
    final last = state.lastSync == null
        ? 'sin sincronizar'
        : 'actualizado ${formatRelative(state.lastSync!)}';

    if (state.syncing) {
      return (AzColors.black, Icons.sync, 'Sincronizando con el servidor…');
    }
    if (state.session?.isPending ?? false) {
      return (AzColors.orange, Icons.schedule, 'Cuenta pendiente de crear en el servidor · $last');
    }
    if (state.needsReauth) {
      return (AzColors.orange, Icons.lock_clock, 'Inicia sesión en línea para sincronizar');
    }
    if (state.online == false) {
      return (Colors.blueGrey.shade700, Icons.cloud_off, 'Sin conexión · catálogo guardado $last');
    }
    return (AzColors.green, Icons.cloud_done, 'En línea · $last');
  }
}
