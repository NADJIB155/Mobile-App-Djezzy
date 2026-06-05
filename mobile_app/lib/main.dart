import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/djezzy_theme.dart';
import 'providers/bts_provider.dart';
import 'providers/task_provider.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';

// COMPOSANT VITAL POUR LE WEB : Permet de glisser/zoomer avec le clic de la souris
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // <-- Active le drag&drop souris
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BtsProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return MaterialApp.router(
      title: 'Djezzy Maintenance Pro',
      theme: DjezzyTheme.lightTheme,
      scrollBehavior: MyCustomScrollBehavior(),
      routerConfig: AppRouter.createRouter(authProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
