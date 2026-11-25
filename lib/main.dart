import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prestamos_app/providers/auth_provider.dart';
import 'package:prestamos_app/providers/prestamo_provider.dart';
import 'package:prestamos_app/screens/login_screen.dart';
import 'package:prestamos_app/screens/main_shell.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(prefs)..cargarSesion(),
        ),
        ChangeNotifierProvider(
          create: (_) => PrestamoProvider()..cargar(),
        ),
      ],
      child: const PrestamosApp(),
    ),
  );
}

class PrestamosApp extends StatelessWidget {
  const PrestamosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final autenticado = context.watch<AuthProvider>().autenticado;

    return MaterialApp(
      title: 'PrestaFácil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: autenticado ? const MainShell() : const LoginScreen(),
    );
  }
}
