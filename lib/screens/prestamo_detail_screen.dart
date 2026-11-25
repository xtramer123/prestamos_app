import 'package:flutter/material.dart';
import 'package:prestamos_app/models/prestamo.dart';
import 'package:prestamos_app/providers/prestamo_provider.dart';
import 'package:prestamos_app/screens/prestamo_form_screen.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:prestamos_app/utils/formatters.dart';
import 'package:prestamos_app/widgets/empty_state.dart';
import 'package:prestamos_app/widgets/estado_badge.dart';
import 'package:prestamos_app/widgets/gradient_button.dart';
import 'package:prestamos_app/widgets/soft_card.dart';
import 'package:provider/provider.dart';

class PrestamoDetailScreen extends StatelessWidget {
  const PrestamoDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrestamoProvider>();
    final prestamo = provider.obtener(id);

    if (prestamo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del préstamo')),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Préstamo no encontrado',
          subtitle: 'Es posible que haya sido eliminado.',
        ),
      );
    }

    void editar() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrestamoFormScreen(prestamo: prestamo),
        ),
      );
    }

    Future<void> eliminar() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar préstamo?'),
          content: Text(
            'Se eliminará el préstamo de ${prestamo.cliente}. Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirmar != true || !context.mounted) return;

      final ok = await provider.eliminar(id);
      if (!context.mounted) return;
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'No se pudo eliminar el préstamo'),
          ),
        );
        provider.limpiarError();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _cabecera(context, prestamo, editar, eliminar),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              children: [
                _progreso(prestamo),
                const SizedBox(height: 16),
                _detalles(prestamo),
                const SizedBox(height: 16),
                _informacion(prestamo),
                if (prestamo.pagado) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este préstamo fue liquidado en su totalidad.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greenDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Editar préstamo',
                  icon: Icons.edit_outlined,
                  onPressed: editar,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.redSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: eliminar,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.red,
                  ),
                  tooltip: 'Eliminar préstamo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecera(
    BuildContext context,
    Prestamo prestamo,
    VoidCallback editar,
    VoidCallback eliminar,
  ) {
    return Stack(
      children: [
        Container(
          height: 290,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Detalle del préstamo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Colors.white),
                      onSelected: (value) {
                        if (value == 'editar') editar();
                        if (value == 'eliminar') eliminar();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.slate),
                              SizedBox(width: 10),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.red),
                              SizedBox(width: 10),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: AppColors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.white,
                      child: Text(
                        AppFormat.initials(prestamo.cliente),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prestamo.cliente,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'DNI ${prestamo.dni}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    EstadoBadge(estado: prestamo.estadoActual),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Total a cobrar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppFormat.money(prestamo.total),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _progreso(Prestamo prestamo) {
    final estado = prestamo.estadoActual;
    final avance = estado == EstadoPrestamo.pagado ? 1.0 : prestamo.avancePlazo;
    final color = estado == EstadoPrestamo.vencido
        ? AppColors.red
        : estado == EstadoPrestamo.pagado
            ? AppColors.slateLight
            : AppColors.green;

    final dias = prestamo.pagado
        ? 'Préstamo liquidado'
        : prestamo.diasRestantes >= 0
            ? '${prestamo.diasRestantes} días para el vencimiento'
            : '${-prestamo.diasRestantes} días de retraso';

    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Avance del plazo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                AppFormat.percent(avance),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: avance,
              minHeight: 9,
              backgroundColor: AppColors.line,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Inicio: ${AppFormat.date(prestamo.fechaPrestamo)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.slate,
                ),
              ),
              const Spacer(),
              Text(
                dias,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detalles(Prestamo prestamo) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dato(Icons.attach_money_rounded, 'Monto prestado',
                    AppFormat.money(prestamo.monto)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dato(Icons.percent_rounded, 'Interés',
                    AppFormat.money(prestamo.interes)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _dato(Icons.calendar_month_outlined, 'Vencimiento',
                    AppFormat.dateShort(prestamo.fechaVencimiento)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dato(Icons.label_outline_rounded, 'Estado',
                    prestamo.estadoActual.label),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _dato(Icons.account_balance_outlined, 'Total',
                    AppFormat.moneyCompact(prestamo.total)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dato(Icons.wallet_outlined, 'Saldo',
                    AppFormat.moneyCompact(prestamo.saldo)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(IconData icon, String label, String valor) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.greenSoft,
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          child: Icon(icon, size: 18, color: AppColors.greenDark),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  color: AppColors.slate,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _informacion(Prestamo prestamo) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del préstamo',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          _fila('Cliente', prestamo.cliente),
          const SizedBox(height: 10),
          _fila('DNI', prestamo.dni),
          const SizedBox(height: 10),
          _fila('Fecha de préstamo', AppFormat.date(prestamo.fechaPrestamo)),
          const SizedBox(height: 10),
          _fila('Fecha de vencimiento',
              AppFormat.date(prestamo.fechaVencimiento)),
          const SizedBox(height: 10),
          _fila('¿Pagado?', prestamo.pagado ? 'Sí' : 'No'),
          const SizedBox(height: 10),
          _fila('ID en la API', '#${prestamo.id}'),
        ],
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.slate,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
