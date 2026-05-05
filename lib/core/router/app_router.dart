// v2.4 — Routing protetto + nuove rotte (sealed envelope, pin change).
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screen.dart';
import '../../features/envelope/sealed_envelope_screen.dart';
import '../../features/heirs/heirs_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/kill_switch/kill_switch_screen.dart';
import '../../features/lock/lock_screen.dart';
import '../../features/lock/pin_setup_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/vault/vault_screen.dart';
import '../state/lock_state.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _LockNotifier();
  ref.listen<bool>(lockProvider, (_, __) => notifier._notify());
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/lock',
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final unlocked = ref.read(lockProvider);
      final loc = state.matchedLocation;

      const publicRoutes = {'/lock', '/auth', '/pin-setup'};
      if (!unlocked && !publicRoutes.contains(loc)) {
        return '/lock';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/lock',
        name: 'lock',
        builder: (_, __) => const LockScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        name: 'pin-setup',
        builder: (_, __) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/vault',
        name: 'vault',
        builder: (_, __) => const VaultScreen(),
      ),
      GoRoute(
        path: '/kill-switch',
        name: 'switch',
        builder: (_, __) => const KillSwitchScreen(),
      ),
      GoRoute(
        path: '/heirs',
        name: 'heirs',
        builder: (_, __) => const HeirsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/sealed-envelope',
        name: 'sealed-envelope',
        builder: (_, __) => const SealedEnvelopeScreen(),
      ),
    ],
  );
});

class _LockNotifier extends ChangeNotifier {
  void _notify() => notifyListeners();
}
