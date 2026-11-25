import 'package:flutter/material.dart';
import 'package:prestamos_app/providers/auth_provider.dart';
import 'package:prestamos_app/providers/prestamo_provider.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:prestamos_app/widgets/soft_card.dart';
import 'package:provider/provider.dart';

import 'main_shell.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificaciones = true;
  bool _confirmaciones = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<PrestamoProvider>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 50),
          children: [
            Text(
              'Mi perfil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.softShadow,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.nombre,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          auth.email,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.slate,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Administrador',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _miniDato('${provider.items.length}', 'Préstamos'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniDato('${provider.cantidadActivos}', 'Activos'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniDato('${provider.cantidadPagados}', 'Pagados'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Mi cuenta',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: EdgeInsets.zero,
              showShadow: true,
              child: Column(
                children: [
                  _fila(Icons.alternate_email_rounded, 'Correo electrónico',
                      auth.email),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _fila(Icons.shield_outlined, 'Rol', 'Administrador'),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _fila(Icons.calendar_today_outlined, 'Miembro desde', '2026'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferencias',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _notificaciones,
                    onChanged: (value) =>
                        setState(() => _notificaciones = value),
                    activeThumbColor: AppColors.green,
                    secondary: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.greenDark,
                    ),
                    title: const Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Avisos sobre el estado de tus préstamos',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 12),
                  SwitchListTile(
                    value: _confirmaciones,
                    onChanged: (value) =>
                        setState(() => _confirmaciones = value),
                    activeThumbColor: AppColors.green,
                    secondary: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.greenDark,
                    ),
                    title: const Text(
                      'Confirmaciones',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Pedir confirmación antes de eliminar',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ayuda',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.greenDark,
                    ),
                    title: const Text(
                      'Cómo usar la aplicación',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.slateLight,
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cómo usar PrestaFácil'),
                        content: const Text(
                          'Desde la pestaña Préstamos puedes registrar un préstamo nuevo, buscarlo, ver su detalle, editarlo o eliminarlo. El botón “Nuevo préstamo” está disponible en Inicio y en la lista.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 12),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.greenDark,
                    ),
                    title: const Text(
                      'Versión de la aplicación',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            OutlinedButton.icon(
              onPressed: () => confirmarSalida(context),
              icon: const Icon(Icons.logout_rounded, size: 19),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: Color(0xFFF6C9C9)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniDato(String valor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.greenDark),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: AppColors.slate,
              ),
            ),
          ),
          Flexible(
            child: Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
