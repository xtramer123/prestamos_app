import 'package:flutter/material.dart';
import 'package:prestamos_app/models/prestamo.dart';
import 'package:prestamos_app/providers/auth_provider.dart';
import 'package:prestamos_app/providers/prestamo_provider.dart';
import 'package:prestamos_app/screens/prestamo_detail_screen.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:prestamos_app/utils/formatters.dart';
import 'package:prestamos_app/widgets/empty_state.dart';
import 'package:prestamos_app/widgets/prestamo_card.dart';
import 'package:prestamos_app/widgets/soft_card.dart';
import 'package:prestamos_app/widgets/stat_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onIrTab,
    required this.onNuevo,
  });

  final ValueChanged<int> onIrTab;
  final VoidCallback onNuevo;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrestamoProvider>();
    final auth = context.watch<AuthProvider>();

    void verDetalle(Prestamo prestamo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrestamoDetailScreen(id: prestamo.id),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${auth.nombre} 👋',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Este es el resumen de tus préstamos',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.greenSoft,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.greenDark,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _tarjetaSaldo(context, provider, onIrTab),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _accion(Icons.add_rounded, 'Nuevo', onNuevo)),
                const SizedBox(width: 12),
                Expanded(
                  child: _accion(
                    Icons.description_outlined,
                    'Préstamos',
                    () => onIrTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _accion(
                    Icons.pie_chart_outline_rounded,
                    'Cartera',
                    () => onIrTab(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_up_rounded,
                    value: '${provider.cantidadActivos}',
                    label: 'Préstamos activos',
                    onTap: () => onIrTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.warning_amber_rounded,
                    value: '${provider.cantidadVencidos}',
                    label: 'Por vencer / vencidos',
                    color: AppColors.red,
                    background: AppColors.redSoft,
                    onTap: () => onIrTab(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.blueSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 19,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${provider.cantidadPagados}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const Text(
                                'Préstamos pagados',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10.5,
                                  color: AppColors.slate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 38, color: AppColors.line),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.amberSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_outlined,
                            size: 19,
                            color: AppColors.amber,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppFormat.moneyCompact(provider.totalIntereses),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const Text(
                                'Intereses generados',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10.5,
                                  color: AppColors.slate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Préstamos recientes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => onIrTab(1),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.items.isEmpty)
              EmptyState(
                icon: Icons.request_quote_outlined,
                title: 'Aún no hay préstamos',
                subtitle: 'Registra tu primer préstamo para empezar a gestionar tu cartera.',
                actionLabel: 'Registrar préstamo',
                onAction: onNuevo,
              )
            else
              ...provider.recientes().map(
                    (prestamo) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PrestamoCard(
                        prestamo: prestamo,
                        onTap: () => verDetalle(prestamo),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaSaldo(
    BuildContext context,
    PrestamoProvider provider,
    ValueChanged<int> onIrTab,
  ) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.greenShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: 70,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Saldo total por cobrar',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => onIrTab(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver cartera',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppFormat.money(provider.totalPorCobrar),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const Spacer(),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.22)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _datoSaldo(
                        'Capital prestado',
                        AppFormat.moneyCompact(provider.totalPrestado),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _datoSaldo(
                        'Total cobrado',
                        AppFormat.moneyCompact(provider.totalCobrado),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoSaldo(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.5,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _accion(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.greenDark),
            ),
            const SizedBox(height: 9),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
