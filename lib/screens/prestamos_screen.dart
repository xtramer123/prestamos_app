import 'package:flutter/material.dart';
import 'package:prestamos_app/models/prestamo.dart';
import 'package:prestamos_app/providers/prestamo_provider.dart';
import 'package:prestamos_app/screens/prestamo_detail_screen.dart';
import 'package:prestamos_app/screens/prestamo_form_screen.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:prestamos_app/widgets/empty_state.dart';
import 'package:prestamos_app/widgets/prestamo_card.dart';
import 'package:provider/provider.dart';

enum _Filtro { todos, activos, vencidos, pagados }

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key, required this.onNuevo});

  final VoidCallback onNuevo;

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final _busquedaController = TextEditingController();
  _Filtro _filtro = _Filtro.todos;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<Prestamo> _filtrar(List<Prestamo> items) {
    final consulta = _busquedaController.text.trim().toLowerCase();
    final filtrados = items.where((prestamo) {
      final coincide = consulta.isEmpty ||
          prestamo.cliente.toLowerCase().contains(consulta) ||
          prestamo.dni.contains(consulta);
      if (!coincide) return false;

      switch (_filtro) {
        case _Filtro.todos:
          return true;
        case _Filtro.activos:
          return prestamo.estadoActual == EstadoPrestamo.activo;
        case _Filtro.vencidos:
          return prestamo.estadoActual == EstadoPrestamo.vencido;
        case _Filtro.pagados:
          return prestamo.estadoActual == EstadoPrestamo.pagado;
      }
    }).toList();

    filtrados.sort((a, b) => b.fechaPrestamo.compareTo(a.fechaPrestamo));
    return filtrados;
  }

  void _verDetalle(Prestamo prestamo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrestamoDetailScreen(id: prestamo.id),
      ),
    );
  }

  Future<void> _editar(Prestamo prestamo) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PrestamoFormScreen(prestamo: prestamo),
      ),
    );
    if (actualizado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préstamo actualizado correctamente')),
      );
    }
  }

  Future<void> _eliminar(Prestamo prestamo) async {
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
    if (confirmar != true || !mounted) return;

    final provider = context.read<PrestamoProvider>();
    final ok = await provider.eliminar(prestamo.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Préstamo eliminado' : (provider.error ?? 'No se pudo eliminar'),
        ),
      ),
    );
    if (ok) provider.limpiarError();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrestamoProvider>();
    final resultados = _filtrar(provider.items);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis préstamos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${provider.items.length} ${provider.items.length == 1 ? 'préstamo registrado' : 'préstamos registrados'}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        size: 14,
                        color: AppColors.greenDark,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Sincronizado',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.redSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 18, color: AppColors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => provider.cargar(),
                      icon: const Icon(Icons.refresh,
                          size: 18, color: AppColors.red),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            TextField(
              controller: _busquedaController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar por cliente o DNI',
                prefixIcon: Icon(Icons.search_rounded, size: 21),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Todos', _Filtro.todos),
                  const SizedBox(width: 8),
                  _chip('Activos', _Filtro.activos),
                  const SizedBox(width: 8),
                  _chip('Vencidos', _Filtro.vencidos),
                  const SizedBox(width: 8),
                  _chip('Pagados', _Filtro.pagados),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: resultados.isEmpty
                  ? EmptyState(
                      icon: provider.items.isEmpty
                          ? Icons.request_quote_outlined
                          : Icons.search_off_rounded,
                      title: provider.items.isEmpty
                          ? 'Aún no hay préstamos'
                          : 'Sin resultados',
                      subtitle: provider.items.isEmpty
                          ? 'Registra tu primer préstamo para empezar.'
                          : 'Prueba con otra búsqueda o cambia el filtro.',
                      actionLabel: provider.items.isEmpty
                          ? 'Registrar préstamo'
                          : 'Limpiar filtros',
                      onAction: provider.items.isEmpty
                          ? widget.onNuevo
                          : () {
                              _busquedaController.clear();
                              setState(() => _filtro = _Filtro.todos);
                            },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 110),
                      itemCount: resultados.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final prestamo = resultados[index];
                        return PrestamoCard(
                          prestamo: prestamo,
                          onTap: () => _verDetalle(prestamo),
                          onEdit: () => _editar(prestamo),
                          onDelete: () => _eliminar(prestamo),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, _Filtro filtro) {
    final seleccionado = _filtro == filtro;
    return ChoiceChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) => setState(() => _filtro = filtro),
      side: BorderSide(
        color: seleccionado ? AppColors.green : AppColors.line,
      ),
    );
  }
}
