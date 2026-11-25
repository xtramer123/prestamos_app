import 'package:flutter/foundation.dart';
import 'package:prestamos_app/models/prestamo.dart';
import 'package:prestamos_app/services/api_service.dart';

class PrestamoProvider extends ChangeNotifier {
  List<Prestamo> _items = <Prestamo>[];
  bool _cargando = true;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;
  List<Prestamo> get items => List.unmodifiable(_items);

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final data = await apiService.get('/prestamos') as List<dynamic>;
      _items = data
          .map((item) => Prestamo.fromJson(item as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (error) {
      _error = error.message;
      _items = [];
    } catch (_) {
      _error = 'No se pudieron cargar los préstamos.';
      _items = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Prestamo? obtener(int id) {
    try {
      return _items.firstWhere((prestamo) => prestamo.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> registrar(Map<String, dynamic> cuerpo) async {
    try {
      final data =
          await apiService.post('/prestamos', body: cuerpo) as Map<String, dynamic>;
      _items = [Prestamo.fromJson(data), ..._items];
      _error = null;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _error = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo registrar el préstamo.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizar(int id, Map<String, dynamic> cuerpo) async {
    try {
      final data = await apiService.put(
        '/prestamos/$id',
        body: cuerpo,
      ) as Map<String, dynamic>;
      final actualizado = Prestamo.fromJson(data);
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) _items[index] = actualizado;
      _error = null;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _error = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo actualizar el préstamo.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminar(int id) async {
    try {
      await apiService.delete('/prestamos/$id');
      _items.removeWhere((prestamo) => prestamo.id == id);
      _error = null;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _error = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo eliminar el préstamo.';
      notifyListeners();
      return false;
    }
  }

  // --- Indicadores del panel ---

  double get totalPrestado =>
      _items.fold(0, (suma, prestamo) => suma + prestamo.monto);

  double get totalPorCobrar => _items
      .where((prestamo) => prestamo.estadoActual != EstadoPrestamo.pagado)
      .fold(0, (suma, prestamo) => suma + prestamo.total);

  double get totalCobrado => _items
      .where((prestamo) => prestamo.pagado)
      .fold(0, (suma, prestamo) => suma + prestamo.total);

  double get totalIntereses =>
      _items.fold(0, (suma, prestamo) => suma + prestamo.interes);

  int get cantidadActivos => _items
      .where((prestamo) => prestamo.estadoActual == EstadoPrestamo.activo)
      .length;

  int get cantidadVencidos => _items
      .where((prestamo) => prestamo.estadoActual == EstadoPrestamo.vencido)
      .length;

  int get cantidadPagados =>
      _items.where((prestamo) => prestamo.pagado).length;

  List<Prestamo> recientes([int limite = 3]) {
    final ordenados = [..._items]
      ..sort((a, b) => b.fechaPrestamo.compareTo(a.fechaPrestamo));
    return ordenados.take(limite).toList();
  }
}
