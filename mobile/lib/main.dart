import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.init();
  runApp(HmdpApp(state: state));
}

class HmdpApp extends StatelessWidget {
  const HmdpApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HMDP Zone',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: ListenableBuilder(
        listenable: state,
        builder: (context, _) => state.isLoggedIn
            ? HomeScreen(key: ValueKey(state.session!.user.email), state: state)
            : LoginScreen(state: state),
      ),
    );
  }
}
