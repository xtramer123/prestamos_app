import 'package:flutter/material.dart';
import 'package:prestamos_app/providers/auth_provider.dart';
import 'package:prestamos_app/providers/prestamo_provider.dart';
import 'package:prestamos_app/screens/home_screen.dart';
import 'package:prestamos_app/screens/perfil_screen.dart';
import 'package:prestamos_app/screens/prestamo_form_screen.dart';
import 'package:prestamos_app/screens/prestamos_screen.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrestamoProvider>().cargar();
    });
  }

  void _irA(int indice) => setState(() => _indice = indice);

  Future<void> _nuevoPrestamo() async {
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PrestamoFormScreen()),
    );
    if (creado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préstamo registrado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<PrestamoProvider>().cargando;

    final paginas = <Widget>[
      HomeScreen(
        onIrTab: _irA,
        onNuevo: _nuevoPrestamo,
      ),
      PrestamosScreen(onNuevo: _nuevoPrestamo),
      const PerfilScreen(),
    ];

    final contenido = SafeArea(
      bottom: false,
      child: cargando
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 18),
                  Text(
                    'Preparando tu información...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            )
          : IndexedStack(index: _indice, children: paginas),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 980) {
          return Scaffold(
            body: Row(
              children: [
                _menuLateral(),
                const VerticalDivider(width: 1, color: AppColors.line),
                Expanded(child: contenido),
              ],
            ),
          );
        }

        return Scaffold(
          body: contenido,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indice,
            onDestinationSelected: _irA,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description_rounded),
                label: 'Préstamos',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
          floatingActionButton: _indice == 2
              ? null
              : FloatingActionButton.extended(
                  onPressed: _nuevoPrestamo,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo préstamo'),
                ),
        );
      },
    );
  }

  Widget _menuLateral() {
    final auth = context.watch<AuthProvider>();
    return Container(
      width: 252,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 26, 20, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.green,
                    size: 29,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'PrestaFácil',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 42),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Text(
                'MENÚ PRINCIPAL',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.slateLight,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _itemMenu(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded,
                'Inicio', 0),
            _itemMenu(Icons.description_outlined, Icons.description_rounded,
                'Préstamos', 1),
            _itemMenu(Icons.person_outline_rounded, Icons.person_rounded,
                'Perfil', 2),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_outlined,
                      size: 17,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Consejo del día',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greenDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mantén tus préstamos al día y actualiza su estado cuando se liquiden.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      height: 1.5,
                      color: AppColors.greenDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: AppColors.greenSoft,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 19,
                      color: AppColors.greenDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          auth.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => confirmarSalida(context),
                    tooltip: 'Cerrar sesión',
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 19,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu(
    IconData icon,
    IconData iconActivo,
    String label,
    int index,
  ) {
    final seleccionado = _indice == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: InkWell(
        onTap: () => _irA(index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: seleccionado ? AppColors.greenSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                seleccionado ? iconActivo : icon,
                size: 21,
                color: seleccionado ? AppColors.greenDark : AppColors.slate,
              ),
              const SizedBox(width: 13),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight:
                      seleccionado ? FontWeight.w600 : FontWeight.w500,
                  color: seleccionado ? AppColors.greenDark : AppColors.slate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> confirmarSalida(BuildContext context) async {
  final salir = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Cerrar sesión?'),
      content: const Text('Necesitarás iniciar sesión de nuevo para continuar.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
  if (salir == true && context.mounted) {
    await context.read<AuthProvider>().cerrarSesion();
  }
}
