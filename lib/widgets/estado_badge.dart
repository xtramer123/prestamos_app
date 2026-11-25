import 'package:flutter/material.dart';
import 'package:prestamos_app/models/prestamo.dart';
import 'package:prestamos_app/theme/app_theme.dart';

class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.estado, this.compact = false});

  final EstadoPrestamo estado;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(estado);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.dot,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 5 : 6),
          Text(
            estado.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: compact ? 10.5 : 11,
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _colors(EstadoPrestamo estado) {
    switch (estado) {
      case EstadoPrestamo.activo:
        return const _BadgeColors(
          AppColors.greenSoft,
          AppColors.green,
          AppColors.greenDark,
        );
      case EstadoPrestamo.pagado:
        return const _BadgeColors(
          Color(0xFFEEF2F6),
          AppColors.slateLight,
          AppColors.slate,
        );
      case EstadoPrestamo.vencido:
        return const _BadgeColors(
          AppColors.redSoft,
          AppColors.red,
          Color(0xFFB91C1C),
        );
    }
  }
}

class _BadgeColors {
  const _BadgeColors(this.background, this.dot, this.foreground);

  final Color background;
  final Color dot;
  final Color foreground;
}
