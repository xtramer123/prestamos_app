enum EstadoPrestamo { activo, vencido, pagado }

extension EstadoPrestamoX on EstadoPrestamo {
  String get label {
    switch (this) {
      case EstadoPrestamo.activo:
        return 'Activo';
      case EstadoPrestamo.vencido:
        return 'Vencido';
      case EstadoPrestamo.pagado:
        return 'Pagado';
    }
  }
}

double _numero(dynamic valor) {
  if (valor is num) return valor.toDouble();
  return double.tryParse(valor.toString()) ?? 0;
}

/// Préstamo tal como lo devuelve la API (tabla `prestamo`).
class Prestamo {
  const Prestamo({
    required this.id,
    required this.cliente,
    required this.dni,
    required this.monto,
    required this.interes,
    required this.fechaPrestamo,
    required this.fechaVencimiento,
    required this.pagado,
    required this.usuarioId,
  });

  final int id;
  final String cliente;
  final String dni;
  final double monto;
  final double interes;
  final DateTime fechaPrestamo;
  final DateTime fechaVencimiento;
  final bool pagado;
  final int usuarioId;

  /// Según la especificación de la API: total = monto + interés.
  double get total => monto + interes;

  double get saldo => pagado ? 0 : total;

  EstadoPrestamo get estadoActual {
    if (pagado) return EstadoPrestamo.pagado;
    if (DateTime.now().isAfter(fechaVencimiento)) {
      return EstadoPrestamo.vencido;
    }
    return EstadoPrestamo.activo;
  }

  int get diasRestantes => fechaVencimiento.difference(DateTime.now()).inDays;

  /// Avance del plazo entre la fecha del préstamo y el vencimiento (0 a 1).
  double get avancePlazo {
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final inicio = fechaPrestamo.millisecondsSinceEpoch;
    final fin = fechaVencimiento.millisecondsSinceEpoch;
    if (fin <= inicio) return 1;
    return ((ahora - inicio) / (fin - inicio)).clamp(0.0, 1.0);
  }

  Prestamo copyWith({
    int? id,
    String? cliente,
    String? dni,
    double? monto,
    double? interes,
    DateTime? fechaPrestamo,
    DateTime? fechaVencimiento,
    bool? pagado,
    int? usuarioId,
  }) {
    return Prestamo(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      dni: dni ?? this.dni,
      monto: monto ?? this.monto,
      interes: interes ?? this.interes,
      fechaPrestamo: fechaPrestamo ?? this.fechaPrestamo,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      pagado: pagado ?? this.pagado,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: (json['id'] as num).toInt(),
      cliente: (json['cliente'] as String?) ?? '',
      dni: (json['dni'] as String?) ?? '',
      monto: _numero(json['monto']),
      interes: _numero(json['interes']),
      fechaPrestamo: DateTime.parse(json['fecha_prestamo'] as String),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento'] as String),
      pagado: (json['pagado'] as bool?) ?? false,
      usuarioId: (json['usuario_id'] as num?)?.toInt() ?? 0,
    );
  }

  /// Cuerpo aceptado por POST /prestamos y PUT /prestamos/{id}.
  Map<String, dynamic> toRequestBody() => {
        'cliente': cliente,
        'dni': dni,
        'monto': monto,
        'interes': interes,
        'fecha_vencimiento':
            '${fechaVencimiento.year.toString().padLeft(4, '0')}-'
            '${fechaVencimiento.month.toString().padLeft(2, '0')}-'
            '${fechaVencimiento.day.toString().padLeft(2, '0')}',
        'pagado': pagado,
      };
}
