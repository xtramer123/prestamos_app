import 'package:flutter_test/flutter_test.dart';
import 'package:prestamos_app/models/prestamo.dart';

void main() {
  test('Cálculo del total según la API (monto + interés)', () {
    final prestamo = Prestamo(
      id: 1,
      cliente: 'Ana Torres',
      dni: '12345678',
      monto: 1000,
      interes: 50,
      fechaPrestamo: DateTime(2026, 1, 1),
      fechaVencimiento: DateTime(2026, 12, 31),
      pagado: false,
      usuarioId: 1,
    );

    expect(prestamo.total, 1050);
    expect(prestamo.saldo, 1050);
    expect(prestamo.estadoActual, EstadoPrestamo.activo);
  });

  test('Préstamo pagado y vencido', () {
    final base = Prestamo(
      id: 2,
      cliente: 'Luis Pérez',
      dni: '87654321',
      monto: 500,
      interes: 25,
      fechaPrestamo: DateTime(2025, 1, 1),
      fechaVencimiento: DateTime(2025, 6, 1),
      pagado: true,
      usuarioId: 1,
    );

    expect(base.estadoActual, EstadoPrestamo.pagado);
    expect(base.saldo, 0);
    expect(
      base.copyWith(pagado: false).estadoActual,
      EstadoPrestamo.vencido,
    );
  });

  test('Serialización con claves de la API', () {
    final prestamo = Prestamo(
      id: 3,
      cliente: 'María López',
      dni: '45678912',
      monto: 1500,
      interes: 150,
      fechaPrestamo: DateTime.parse('2026-11-25'),
      fechaVencimiento: DateTime.parse('2027-05-24'),
      pagado: false,
      usuarioId: 7,
    );

    final datos = {
      'id': 3,
      'cliente': 'María López',
      'dni': '45678912',
      'monto': '1500.00',
      'interes': '150.00',
      'fecha_prestamo': '2026-11-25',
      'fecha_vencimiento': '2027-05-24',
      'pagado': false,
      'usuario_id': 7,
    };

    final copia = Prestamo.fromJson(datos);
    expect(copia.total, 1650);
    expect(copia.usuarioId, 7);
    expect(copia.toRequestBody()['dni'], '45678912');
    expect(prestamo.total, copia.total);
  });
}
