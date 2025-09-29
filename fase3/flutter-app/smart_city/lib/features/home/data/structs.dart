class Alerta {
  final String id;
  final String tipo;
  final String data;
  final DateTime timestamp;

  Alerta({required this.id, required this.tipo, required this.data, required this.timestamp});

  factory Alerta.fromJson(Map<String, dynamic> json) => Alerta(
        id: json['id'] as String,
        tipo: json['tipo'] as String,
        data: json['data'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class Trafico {
  final List<String> semaforos;
  final DateTime timestamp;

  Trafico({required this.semaforos, required this.timestamp});

  factory Trafico.fromJson(Map<String, dynamic> json) => Trafico(
        semaforos: (json['semaforos'] as List<dynamic>).map((e) => e.toString()).toList(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class Ambiente {
  final List<Map<String, num>> mqSensors;
  final DateTime timestamp;

  Ambiente({required this.mqSensors, required this.timestamp});

  factory Ambiente.fromJson(Map<String, dynamic> json) => Ambiente(
        mqSensors: (json['mq_sensors'] as List<dynamic>).map((e) => Map<String, num>.from(e as Map)).toList(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
