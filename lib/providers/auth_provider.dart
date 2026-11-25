import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:prestamos_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._prefs);

  final SharedPreferences _prefs;

  static const String _tokenKey = 'api_token';
  static const String _usuarioKey = 'api_usuario';

  bool _autenticado = false;
  bool _cargando = false;
  Map<String, dynamic>? _usuario;
  String? _error;

  bool get autenticado => _autenticado;
  bool get cargando => _cargando;
  String? get error => _error;
  Map<String, dynamic>? get usuario => _usuario;

  String get nombre => (_usuario?['nombre'] as String?) ?? 'Usuario';
  String get email => (_usuario?['email'] as String?) ?? '';
  String get rol => (_usuario?['rol'] as String?) ?? 'USER';

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void cargarSesion() {
    final token = _prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return;

    apiService.setToken(token);
    final guardado = _prefs.getString(_usuarioKey);
    if (guardado != null) {
      try {
        _usuario = Map<String, dynamic>.from(jsonDecode(guardado) as Map);
      } catch (_) {
        _usuario = null;
      }
    }
    _autenticado = true;
  }

  Future<bool> iniciarSesion(
    String email,
    String password, {
    bool recordar = true,
  }) async {
    return _autenticar(
      '/auth/login',
      {'email': email.trim(), 'password': password},
      recordar,
    );
  }

  Future<bool> registrar(
    String nombre,
    String email,
    String password, {
    bool recordar = true,
  }) async {
    return _autenticar(
      '/auth/register',
      {
        'nombre': nombre.trim(),
        'email': email.trim(),
        'password': password,
      },
      recordar,
    );
  }

  Future<bool> _autenticar(
    String ruta,
    Map<String, dynamic> cuerpo,
    bool recordar,
  ) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await apiService.post(ruta, body: cuerpo) as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final usuario = Map<String, dynamic>.from(
        data['usuario'] as Map<String, dynamic>,
      );

      apiService.setToken(token);
      _usuario = usuario;
      _autenticado = true;

      if (recordar) {
        await _prefs.setString(_tokenKey, token);
        await _prefs.setString(_usuarioKey, jsonEncode(usuario));
      } else {
        await _prefs.remove(_tokenKey);
        await _prefs.remove(_usuarioKey);
      }
      return true;
    } on ApiException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'No se pudo completar la operación. Intenta de nuevo.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_usuarioKey);
    apiService.setToken(null);
    _autenticado = false;
    _usuario = null;
    _error = null;
    notifyListeners();
  }
}
