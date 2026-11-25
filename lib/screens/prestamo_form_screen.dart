import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prestamos_app/models/prestamo.dart';
import 'package:prestamos_app/providers/prestamo_provider.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:prestamos_app/utils/formatters.dart';
import 'package:prestamos_app/widgets/gradient_button.dart';
import 'package:prestamos_app/widgets/soft_card.dart';
import 'package:provider/provider.dart';

class PrestamoFormScreen extends StatefulWidget {
  const PrestamoFormScreen({super.key, this.prestamo});

  final Prestamo? prestamo;

  @override
  State<PrestamoFormScreen> createState() => _PrestamoFormScreenState();
}

class _PrestamoFormScreenState extends State<PrestamoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _dniController = TextEditingController();
  final _montoController = TextEditingController();
  final _interesController = TextEditingController();

  late DateTime _fechaVencimiento;
  late bool _pagado;
  bool _guardando = false;

  bool get _editando => widget.prestamo != null;

  @override
  void initState() {
    super.initState();
    final prestamo = widget.prestamo;
    if (prestamo != null) {
      _clienteController.text = prestamo.cliente;
      _dniController.text = prestamo.dni;
      _montoController.text = prestamo.monto.toStringAsFixed(2);
      _interesController.text = prestamo.interes.toStringAsFixed(2);
      _fechaVencimiento = prestamo.fechaVencimiento;
      _pagado = prestamo.pagado;
    } else {
      _fechaVencimiento = DateTime.now().add(const Duration(days: 180));
      _pagado = false;
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _dniController.dispose();
    _montoController.dispose();
    _interesController.dispose();
    super.dispose();
  }

  double get _monto => _numero(_montoController.text);
  double get _interes => _numero(_interesController.text);
  double get _total => _monto + _interes;

  double _numero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _elegirFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      helpText: 'Fecha de vencimiento',
    );
    if (seleccionada != null) {
      setState(() => _fechaVencimiento = seleccionada);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final cuerpo = {
      'cliente': _clienteController.text.trim(),
      'dni': _dniController.text.trim(),
      'monto': _monto,
      'interes': _interes,
      'fecha_vencimiento':
          '${_fechaVencimiento.year.toString().padLeft(4, '0')}-'
          '${_fechaVencimiento.month.toString().padLeft(2, '0')}-'
          '${_fechaVencimiento.day.toString().padLeft(2, '0')}',
      'pagado': _pagado,
    };

    final provider = context.read<PrestamoProvider>();
    final ok = _editando
        ? await provider.actualizar(widget.prestamo!.id, cuerpo)
        : await provider.registrar(cuerpo);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      Navigator.pop<bool>(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'No se pudo guardar el préstamo'),
        ),
      );
      provider.limpiarError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(_editando ? 'Editar préstamo' : 'Nuevo préstamo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
          children: [
            _tituloSeccion(Icons.person_outline_rounded, 'Datos del cliente'),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _clienteController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del cliente',
                      hintText: 'Ej. María Fernanda López',
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Ingresa el nombre del cliente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'DNI',
                      hintText: '8 dígitos',
                      prefixIcon: Icon(Icons.credit_card_outlined, size: 20),
                    ),
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^\d{8}$').hasMatch(value)) {
                        return 'El DNI debe tener 8 dígitos';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _tituloSeccion(Icons.account_balance_wallet_outlined,
                'Condiciones del préstamo'),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _montoController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Monto prestado',
                            hintText: '0.00',
                            prefixIcon:
                                Icon(Icons.attach_money_rounded, size: 20),
                          ),
                          validator: (value) {
                            if (_numero(value ?? '') <= 0) {
                              return 'Monto mayor a 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _interesController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Interés',
                            hintText: '0.00',
                            suffixText: '\$',
                            suffixStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.slate,
                            ),
                          ),
                          validator: (value) {
                            if (_numero(value ?? '') < 0) {
                              return 'No puede ser negativo';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _elegirFecha,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de vencimiento',
                        prefixIcon: Icon(Icons.calendar_today_outlined,
                            size: 19),
                      ),
                      child: Row(
                        children: [
                          Text(
                            AppFormat.date(_fechaVencimiento),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19,
                            color: AppColors.slate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _pagado,
                    onChanged: (value) => setState(() => _pagado = value),
                    activeThumbColor: AppColors.green,
                    secondary: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.greenDark,
                    ),
                    title: const Text(
                      'Préstamo pagado',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Marca este préstamo como liquidado',
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
            _tituloSeccion(Icons.calculate_outlined, 'Resumen'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _fila('Monto prestado', AppFormat.money(_monto)),
                  const SizedBox(height: 12),
                  _fila('Interés', AppFormat.money(_interes)),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.green.withValues(alpha: 0.15)),
                  const SizedBox(height: 12),
                  _fila('Total a cobrar', AppFormat.money(_total),
                      destacado: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
        child: SafeArea(
          top: false,
          child: GradientButton(
            label: _editando ? 'Guardar cambios' : 'Registrar préstamo',
            icon: Icons.save_outlined,
            loading: _guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }

  Widget _tituloSeccion(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.greenDark),
        const SizedBox(width: 9),
        Text(
          texto,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _fila(String label, String valor, {bool destacado = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.greenDark,
          ),
        ),
        const Spacer(),
        Text(
          valor,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: destacado ? 16 : 12.5,
            fontWeight: destacado ? FontWeight.w700 : FontWeight.w600,
            color: destacado ? AppColors.greenDeep : AppColors.ink,
          ),
        ),
      ],
    );
  }
}
