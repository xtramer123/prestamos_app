import 'package:flutter/material.dart';
import 'package:prestamos_app/models/prestamo.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:prestamos_app/utils/formatters.dart';
import 'package:prestamos_app/widgets/estado_badge.dart';
import 'package:prestamos_app/widgets/soft_card.dart';

class PrestamoCard extends StatelessWidget {
  const PrestamoCard({
    super.key,
    required this.prestamo,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Prestamo prestamo;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final estado = prestamo.estadoActual;
    final avance = estado == EstadoPrestamo.pagado ? 1.0 : prestamo.avancePlazo;
    final colorProgreso = estado == EstadoPrestamo.vencido
        ? AppColors.red
        : estado == EstadoPrestamo.pagado
            ? AppColors.slateLight
            : AppColors.green;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(15, 15, 8, 15),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.greenSoft,
            child: Text(
              AppFormat.initials(prestamo.cliente),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prestamo.cliente,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    EstadoBadge(estado: estado, compact: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'DNI ${prestamo.dni}  ·  ${AppFormat.money(prestamo.monto)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: AppColors.slate,
                  ),
                ),
                const SizedBox(height: 11),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: avance,
                    minHeight: 6,
                    backgroundColor: AppColors.line,
                    color: colorProgreso,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      'Total ${AppFormat.moneyCompact(prestamo.total)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorProgreso,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Vence ${AppFormat.dateShort(prestamo.fechaVencimiento)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        color: AppColors.slateLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.slateLight,
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'ver') onTap();
                if (value == 'editar') onEdit?.call();
                if (value == 'eliminar') onDelete?.call();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ver',
                  child: _MenuTile(
                    icon: Icons.visibility_outlined,
                    label: 'Ver detalle',
                  ),
                ),
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'editar',
                    child: _MenuTile(icon: Icons.edit_outlined, label: 'Editar'),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: _MenuTile(
                      icon: Icons.delete_outline,
                      label: 'Eliminar',
                      danger: true,
                    ),
                  ),
              ],
            )
          else
            const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: danger ? AppColors.red : AppColors.slate,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: danger ? AppColors.red : AppColors.ink,
          ),
        ),
      ],
    );
  }
}
