import 'package:flutter/material.dart';
import 'package:prestamos_app/providers/auth_provider.dart';
import 'package:prestamos_app/services/api_service.dart';
import 'package:prestamos_app/theme/app_theme.dart';
import 'package:prestamos_app/widgets/gradient_button.dart';
import 'package:prestamos_app/widgets/soft_card.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _modoRegistro = false;
  bool _obscurePassword = true;
  bool _recordar = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final ok = _modoRegistro
        ? await auth.registrar(
            _nombreController.text,
            _emailController.text,
            _passwordController.text,
            recordar: _recordar,
          )
        : await auth.iniciarSesion(
            _emailController.text,
            _passwordController.text,
            recordar: _recordar,
          );

    if (!mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error ?? 'No se pudo completar la operación')),
    );
  }

  void _llenarDemo() {
    _emailController.text = 'admin@prestafacil.com';
    _passwordController.text = '123456';
    setState(() => _modoRegistro = false);
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AuthProvider>().cargando;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              children: [
                Expanded(flex: 55, child: _panelMarca(grande: true)),
                Expanded(
                  flex: 45,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: _formulario(cargando),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _panelMarca(grande: false),
                Transform.translate(
                  offset: const Offset(0, -34),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SoftCard(
                      radius: 26,
                      padding: const EdgeInsets.all(24),
                      child: _formulario(cargando),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Text(
                    '© 2026 PrestaFácil · Todos los derechos reservados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      color: AppColors.slateLight,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _panelMarca({required bool grande}) {
    final height = grande ? null : 292.0;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: grande
            ? null
            : const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -70,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: grande ? 52 : 26,
                vertical: grande ? 44 : 22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: grande ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: grande ? 50 : 44,
                        height: grande ? 50 : 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greenDeep.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.green,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'PrestaFácil',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: grande ? 76 : 26),
                  Text(
                    grande
                        ? 'Gestiona tus préstamos\ncon total claridad.'
                        : 'Tu cartera de préstamos,\nen un solo lugar.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: grande ? 40 : 23,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: grande ? -1.4 : -0.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Registra, consulta y actualiza cada préstamo conectado a tu API local.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: grande ? 14.5 : 12.5,
                      height: 1.6,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  if (grande) ...[
                    const SizedBox(height: 44),
                    _rasgo(Icons.cloud_done_outlined, 'Datos sincronizados con la API'),
                    const SizedBox(height: 16),
                    _rasgo(Icons.manage_accounts_rounded, 'Administra cada préstamo fácilmente'),
                    const SizedBox(height: 16),
                    _rasgo(Icons.verified_user_rounded, 'Acceso protegido con JWT'),
                    const Spacer(),
                    Text(
                      '© 2026 PrestaFácil · Hecho para simplificar tu gestión',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rasgo(IconData icon, String texto) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 14),
        Text(
          texto,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _formulario(bool cargando) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _modoRegistro ? 'Crear cuenta' : 'Iniciar sesión',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _modoRegistro
              ? 'Regístrate como prestamista para comenzar'
              : 'Ingresa tus credenciales para continuar',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            color: AppColors.slate,
          ),
        ),
        const SizedBox(height: 26),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_modoRegistro) ...[
                TextFormField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del prestamista',
                    hintText: 'Ej. Isaac Administrador',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'tu@correo.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo electrónico';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _enviar(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'Debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 32,
                    child: Checkbox(
                      value: _recordar,
                      onChanged: (value) =>
                          setState(() => _recordar = value ?? false),
                      activeColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Mantener sesión iniciada',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GradientButton(
                label: _modoRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                icon: _modoRegistro ? Icons.person_add_alt_1 : Icons.login_rounded,
                loading: cargando,
                onPressed: _enviar,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _modoRegistro ? '¿Ya tienes cuenta?' : '¿No tienes cuenta?',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: AppColors.slate,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _modoRegistro = !_modoRegistro),
              child: Text(_modoRegistro ? 'Inicia sesión' : 'Regístrate'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.greenSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_done_outlined,
                  size: 18,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API local conectada',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenDeep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      apiService.baseUrl,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        color: AppColors.greenDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_modoRegistro)
                TextButton(
                  onPressed: _llenarDemo,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Usar demo'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
