import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/home_drawer.dart';
import '../../../home/data/api_client.dart';
import '../../data/structs.dart';

// para manejar el umbral en los mqSensors
const Map<int, Map<String, double>> kSensorAbsoluteOverrides = {
  0: {
    'greenUpTo': 200,
    'amberUpTo': 250,
    'redAbove': 300,
  },
  1: {
    'greenUpTo': 200,
    'amberUpTo': 250,
    'redAbove': 300,
  },
  2: {
    'greenUpTo': 10,
    'amberUpTo': 15,
    'redAbove': 19, 
  },
};

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Control')),
      drawer: const HomeDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TrafficSection(),
          SizedBox(height: 12),
          AmbientSection(),
          SizedBox(height: 12),
          AlertsSection(),
          SizedBox(height: 12),
          AlertsByTypeSection(),
          SizedBox(height: 12),
          AlertsPieCountSection(),
          SizedBox(height: 12),
          TopPersonasSection(),
          SizedBox(height: 12),
          TopArmasSection(),
          SizedBox(height: 12),
          InfraccionesSection(),
        ],
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? fixedHeight; // ayuda pa que no se mueva cuando se actualicen las cosas
  const KpiCard({super.key, required this.title, required this.child, this.fixedHeight});

  @override
  Widget build(BuildContext context) {
    Widget buildContent({required bool constrained}) {
      final children = <Widget>[
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (constrained)
          Expanded(child: child)
        else
          child,
      ];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: fixedHeight == null
            ? buildContent(constrained: false)
            : SizedBox(height: fixedHeight, child: buildContent(constrained: true)),
      ),
    );
  }
}

// Sección de tráfico
class TrafficSection extends StatefulWidget {
  const TrafficSection({super.key});

  @override
  State<TrafficSection> createState() => _TrafficSectionState();
}

class _TrafficSectionState extends State<TrafficSection> {
  final _api = ApiClient();
  List<Trafico> _data = const [];
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_loading) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.fetchTrafico();
      setState(() {
        _data = res;
        _loading = false;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _data.isNotEmpty;
  final latest = hasData ? _data.first : null;
    
    List<String> estados = latest?.semaforos.toList() ?? <String>[];
    const desired = 11;
    if (estados.length < desired) {
      estados.addAll(List.filled(desired - estados.length, 'off'));
    } else if (estados.length > desired) {
      estados = estados.take(desired).toList();
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lastUpdate != null && hasData) Text('Actualizado: ${_lastUpdate!.toLocal()}'),
        if (hasData) const SizedBox(height: 8),
        _trafficSummary(estados),
        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            int cross = 4;
            if (w < 420) cross = 3;
            if (w > 800) cross = 6;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: estados.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (_, i) => Center(
                child: SemaforoWidget(index: i + 1, estado: estados[i]),
              ),
            );
          },
        ),
      ],
    );
    
    return KpiCard(
      title: 'Tráfico',
      child: hasData
          ? Stack(
              children: [
                AnimatedOpacity(
                  opacity: _loading ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: content,
                ),
                if (_error != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Text('Error', style: TextStyle(color: Colors.red.shade700)),
                            const SizedBox(width: 8),
                            TextButton(onPressed: _load, child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_loading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
              ],
            )
          : content,
    );
  }

  // conteo semaforos
  Widget _trafficSummary(List<String> semaforos) {
    final s = semaforos.map((e) => e.toLowerCase()).toList();
    final rojo = s.where((e) => e == 'rojo').length;
    final amarillo = s.where((e) => e == 'amarillo').length;
    final verde = s.where((e) => e == 'verde').length;
    Widget badge(Color c, String label, int v) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('$label: $v'),
          ]),
        );
    return Wrap(
      spacing: 8,
      children: [
        badge(Colors.red, 'Rojo', rojo),
        badge(Colors.amber, 'Amarillo', amarillo),
        badge(Colors.green, 'Verde', verde),
      ],
    );
  }
}

// widget para cada semaforo
class SemaforoWidget extends StatelessWidget {
  final int index;
  final String estado;
  const SemaforoWidget({super.key, required this.index, required this.estado});

  @override
  Widget build(BuildContext context) {
    final lower = estado.toLowerCase();
    bool on(String c) => lower == c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('S$index', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          width: 38,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _light(color: Colors.red, active: on('rojo')),
              const SizedBox(height: 6),
              _light(color: Colors.amber, active: on('amarillo')),
              const SizedBox(height: 6),
              _light(color: Colors.green, active: on('verde')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _light({required Color color, required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
    );
  }
}

// Sección de ambiente
class AmbientSection extends StatefulWidget {
  const AmbientSection({super.key});

  @override
  State<AmbientSection> createState() => _AmbientSectionState();
}

class _AmbientSectionState extends State<AmbientSection> {
  final _api = ApiClient();
  List<Ambiente> _data = const [];
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdate;
  Timer? _timer;

  // el mqMax conforme umbral jeje
  static const double mqMin = 0;
  static const double mqMax = 600;
  static const String mqUnits = 'ppm';

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_loading) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.fetchAmbiente();
      setState(() {
        _data = res;
        _loading = false;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _data.isNotEmpty;
    final latest = hasData ? _data.first : null;
    final sensors = latest?.mqSensors ?? <Map<String, num>>[];
    
    List<Map<String, num>> three = List<Map<String, num>>.from(sensors);
    if (three.length < 3) {
      three.addAll(List.generate(3 - three.length, (_) => const {}));
    } else if (three.length > 3) {
      three = three.take(3).toList();
    }
    // para mostrar los 3 semicirculos
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lastUpdate != null && hasData) Text('Actualizado: ${_lastUpdate!.toLocal()}'),
        if (hasData) const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: SemicircleGauge(
                      sensorId: (three[i]['id'] ?? (i + 1)).toInt(),
                      label: 'MQ${(three[i]['id'] ?? (i + 1)).toInt()}',
                      value: three[i].containsKey('nivel') ? (three[i]['nivel'] as num).toDouble() : null,
                      min: mqMin,
                      max: mqMax,
                      units: mqUnits,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );

    return KpiCard(
      title: 'Ambiente',
      child: hasData
          ? Stack(
              children: [
                AnimatedOpacity(
                  opacity: _loading ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: content,
                ),
                if (_error != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Text('Error', style: TextStyle(color: Colors.red.shade700)),
                            const SizedBox(width: 8),
                            TextButton(onPressed: _load, child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_loading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
              ],
            )
          : content,
    );
  }
}

// ratio 0..1
class SemicircleGauge extends StatelessWidget {
  final int? sensorId;
  final String label;
  final double? value;
  final double min;
  final double max;
  final String units;
  final double strokeWidth;

  const SemicircleGauge({
    super.key,
    this.sensorId,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 1023,
    this.units = '',
    this.strokeWidth = 14,
  });

  Color _colorFor(double ratio, double currentValue) {
    // para que exista la opción de que sea porcetaje o por un valor fijo
    if (sensorId != null && kSensorAbsoluteOverrides.containsKey(sensorId)) {
      final ov = kSensorAbsoluteOverrides[sensorId]!;
      final greenUpTo = ov['greenUpTo'] ?? currentValue;
      final amberUpTo = ov['amberUpTo'] ?? currentValue;
      final redAbove  = ov['redAbove']  ?? currentValue;
      if (currentValue <= greenUpTo) return Colors.green;
      if (currentValue <= amberUpTo) return Colors.amber;
      if (currentValue > redAbove) return Colors.red;
      return Colors.amber;
    }
    // aquí se manejan los porcentajes
    if (ratio <= 1 / 3) return Colors.green;
    if (ratio <= 2 / 3) return Colors.amber;
    return Colors.red;
  }
  // widget pa el semicirculo
  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && max > min;
    final ratio = hasValue ? ((value! - min) / (max - min)).clamp(0.0, 1.0) : 0.0;
  final color = _colorFor(ratio, value ?? min);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 2,
          child: CustomPaint(
            painter: _SemicircleGaugePainter(
              ratio: ratio,
              color: color,
              strokeWidth: strokeWidth,
              trackColor: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hasValue ? '${value!.toStringAsFixed(0)}${units.isNotEmpty ? ' $units' : ''}' : '—',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

// para pintar el semicirculo
class _SemicircleGaugePainter extends CustomPainter {
  final double ratio; // 0..1
  final Color color;
  final double strokeWidth;
  final Color trackColor;

  _SemicircleGaugePainter({
    required this.ratio,
    required this.color,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = math.min(w / 2, h - strokeWidth) - strokeWidth / 2;
    final center = Offset(w / 2, h - strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: r);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = trackColor;

    canvas.drawArc(rect, math.pi, math.pi, false, base);
    
    if (ratio > 0) {
      final prog = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = color;
      final sweep = (ratio * math.pi).clamp(0.0, math.pi);
      canvas.drawArc(rect, math.pi, sweep, false, prog);
    }
  }

  @override
  bool shouldRepaint(covariant _SemicircleGaugePainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor;
  }
}

// Sección de alertas
class AlertsSection extends StatefulWidget {
  const AlertsSection({super.key});

  @override
  State<AlertsSection> createState() => _AlertsSectionState();
}

class _AlertsSectionState extends State<AlertsSection> {
  final _api = ApiClient();
  List<Alerta> _data = const [];
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdate;
  String _window = '24h';
  Timer? _timer;
  static const int _alertsLimit = 60; // para que se use la petición /alertas/60

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted && !_loading) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
  final res = await _api.fetchAlertas(limit: _alertsLimit);
      setState(() {
        _data = res;
        _loading = false;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _data.isNotEmpty;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lastUpdate != null) Text('Actualizado: ${_lastUpdate!.toLocal()}'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Ventana:'),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _window,
              items: const [
                DropdownMenuItem(value: 'hoy', child: Text('Hoy')),
                DropdownMenuItem(value: '24h', child: Text('24h')),
                DropdownMenuItem(value: '7d', child: Text('7 días')),
              ],
              onChanged: (v) => setState(() => _window = v ?? '24h'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _alertKpisRow(_data, _window),
        const SizedBox(height: 12),
        SizedBox(height: 180, child: _alertsBarChart(_data, _window)),
        const SizedBox(height: 8),
        const Text('El feed detallado está en su pantalla dedicada.'),
      ],
    );

    return KpiCard(
      title: 'Alertas',
      child: hasData
          ? Stack(
              children: [
                AnimatedOpacity(
                  opacity: _loading ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: content,
                ),
                if (_error != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Text('Error', style: TextStyle(color: Colors.red.shade700)),
                            const SizedBox(width: 8),
                            TextButton(onPressed: _load, child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_loading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
              ],
            )
          : (_loading
              ? const Center(child: CircularProgressIndicator())
              : content),
    );
  }

  Iterable<Alerta> _filterAlerts(List<Alerta> als, String window) {
    if (als.isEmpty) return als;
    final now = DateTime.now().toUtc();
    DateTime from;
    switch (window) {
      case 'hoy':
        final localNow = DateTime.now();
        final startOfDay = DateTime(localNow.year, localNow.month, localNow.day);
        from = startOfDay.toUtc();
        break;
      case '7d':
        from = now.subtract(const Duration(days: 7));
        break;
      case '24h':
      default:
        from = now.subtract(const Duration(hours: 24));
    }
    return als.where((a) => a.timestamp.toUtc().isAfter(from));
  }

  Widget _alertKpisRow(List<Alerta> als, String window) {
    final filtered = _filterAlerts(als, window).toList();
    int count(String t) => filtered.where((a) => a.tipo.toLowerCase() == t).length;
    final sismo = count('sismo');
    final panico = count('panico');
    final incendio = count('incendio');
    final infraccion = count('infraccion');

    Widget kpi(String title, int v, Color c) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text('$v', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );

    return Row(
      children: [
        kpi('Sismo', sismo, Colors.red),
        const SizedBox(width: 8),
        kpi('Pánico', panico, Colors.orange),
        const SizedBox(width: 8),
        kpi('Incendio', incendio, Colors.deepOrange),
        const SizedBox(width: 8),
        kpi('Infracción', infraccion, Colors.blue),
      ],
    );
  }

  Widget _alertsBarChart(List<Alerta> als, String window) {
    final filtered = _filterAlerts(als, window).toList();
    final types = ['sismo', 'panico', 'incendio', 'infraccion'];
    final counts = {
      for (final t in types) t: filtered.where((a) => a.tipo.toLowerCase() == t).length.toDouble()
    };

    final bars = <BarChartGroupData>[];
    int x = 0;
    for (final t in types) {
      final color = {
        'sismo': Colors.red,
        'panico': Colors.orange,
        'incendio': Colors.deepOrange,
        'infraccion': Colors.blue,
      }[t]!;

      bars.add(
        BarChartGroupData(
          x: x++,
          barRods: [BarChartRodData(toY: counts[t]!, color: color, width: 16, borderRadius: BorderRadius.circular(4))],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(types[value.toInt()].substring(0, 3).toUpperCase(), style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ),
        barGroups: bars,
      ),
    );
  }
}

// FILTRADO POR TIPO DE DATOS
class AlertsByTypeSection extends StatefulWidget {
  const AlertsByTypeSection({super.key});

  @override
  State<AlertsByTypeSection> createState() => _AlertsByTypeSectionState();
}

class _AlertsByTypeSectionState extends State<AlertsByTypeSection> {
  final _api = ApiClient();
  List<Alerta> _data = const [];
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdate;
  String _selected = 'todas';
  Timer? _timer;
  static const int _alertsLimit = 60; // lo histórico que se carga

  static const List<String> _types = ['sismo', 'panico', 'incendio', 'infraccion'];

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted && !_loading) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.fetchAlertas(limit: _alertsLimit);
      setState(() {
        _data = res;
        _loading = false;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _data.isNotEmpty;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lastUpdate != null) Text('Actualizado: ${_lastUpdate!.toLocal()}'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Tipo:'),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selected,
              items: const [
                DropdownMenuItem(value: 'todas', child: Text('Todas')),
                DropdownMenuItem(value: 'sismo', child: Text('Sismo')),
                DropdownMenuItem(value: 'panico', child: Text('Pánico')),
                DropdownMenuItem(value: 'incendio', child: Text('Incendio')),
                DropdownMenuItem(value: 'infraccion', child: Text('Infracción')),
              ],
              onChanged: (v) => setState(() => _selected = v ?? 'todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: _selected == 'todas' ? _pieAll() : _barByTypeTotal(_selected),
        ),
      ],
    );

    return KpiCard(
      title: 'Alertas por tipo',
      child: hasData
          ? Stack(
              children: [
                AnimatedOpacity(
                  opacity: _loading ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: content,
                ),
                if (_error != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Text('Error', style: TextStyle(color: Colors.red.shade700)),
                            const SizedBox(width: 8),
                            TextButton(onPressed: _load, child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_loading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
              ],
            )
          : (_loading
              ? const Center(child: CircularProgressIndicator())
              : content),
    );
  }

  Widget _pieAll() {
    final counts = {
      for (final t in _types) t: _data.where((a) => a.tipo.toLowerCase() == t).length.toDouble()
    };
    final colors = {
      'sismo': Colors.red,
      'panico': Colors.orange,
      'incendio': Colors.deepOrange,
      'infraccion': Colors.blue,
    };
    final sections = _types
        .map((t) => PieChartSectionData(
              value: counts[t]!,
              color: colors[t]!,
              title: counts[t]!.toInt().toString(),
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ))
        .toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _types
              .map((t) => Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 10, height: 10, color: colors[t]),
                    const SizedBox(width: 6),
                    Text('${t[0].toUpperCase()}${t.substring(1)} (${counts[t]!.toInt()})'),
                  ]))
              .toList(),
        ),
      ],
    );
  }

  // para que la grafica por cada tipo sea en una barra horizontal
  Widget _barByTypeTotal(String type) {
    final typeLc = type.toLowerCase();
    final totalOfType = _data.where((a) => a.tipo.toLowerCase() == typeLc).length;
    final maxCount = totalOfType == 0 ? 1 : totalOfType; 

    final color = {
      'sismo': Colors.red,
      'panico': Colors.orange,
      'incendio': Colors.deepOrange,
      'infraccion': Colors.blue,
    }[typeLc] ?? Colors.teal;

    final tickFractions = const [0.0, 0.25, 0.5, 0.75, 1.0];
    final tickLabels = tickFractions.map((f) => (maxCount * f).round()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total ${typeLc[0].toUpperCase()}${typeLc.substring(1)}: $totalOfType'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final barHeight = 22.0;
            final bg = Theme.of(context).dividerColor.withValues(alpha: 0.3);
            return Column(
              children: [
                // pa que siempre esté la barra llena 
                Stack(
                  children: [
                    Container(
                      width: w,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // total rellenado
                    Container(
                      width: w * (totalOfType / maxCount),
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 10,
                        child: Stack(
                          children: List.generate(tickFractions.length, (i) {
                            final left = (w - 1) * tickFractions[i];
                            return Positioned(
                              left: left,
                              top: 0,
                              child: Container(width: 1, height: 10, color: Colors.black26),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: tickLabels
                            .map((v) => Text('$v', style: const TextStyle(fontSize: 10, color: Colors.black54)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

}

// grafica pero por cantidad
class AlertsPieCountSection extends StatefulWidget {
  const AlertsPieCountSection({super.key});

  @override
  State<AlertsPieCountSection> createState() => _AlertsPieCountSectionState();
}

class _AlertsPieCountSectionState extends State<AlertsPieCountSection> {
  final _api = ApiClient();
  List<Alerta> _data = const [];
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdate;
  Timer? _timer;
  String _selCount = 'todas';
  static const int _alertsLimit = 60; // lo histórico que se carga
  static const List<String> _types = ['sismo', 'panico', 'incendio', 'infraccion'];

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted && !_loading) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.fetchAlertas(limit: _alertsLimit);
      setState(() {
        _data = res;
        _loading = false;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _data.isNotEmpty;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lastUpdate != null) Text('Actualizado: ${_lastUpdate!.toLocal()}'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Cantidad:'),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selCount,
              items: const [
                DropdownMenuItem(value: '10', child: Text('Últimos 10')),
                DropdownMenuItem(value: '20', child: Text('Últimos 20')),
                DropdownMenuItem(value: '40', child: Text('Últimos 40')),
                DropdownMenuItem(value: '60', child: Text('Últimos 60')),
                DropdownMenuItem(value: 'todas', child: Text('Todas')),
              ],
              onChanged: (v) => setState(() => _selCount = v ?? 'todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(height: 220, child: _pieForSelection()),
      ],
    );

    return KpiCard(
      title: 'Alertas por cantidad',
      child: hasData
          ? Stack(
              children: [
                AnimatedOpacity(
                  opacity: _loading ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: content,
                ),
                if (_error != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Text('Error', style: TextStyle(color: Colors.red.shade700)),
                            const SizedBox(width: 8),
                            TextButton(onPressed: _load, child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_loading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
              ],
            )
          : (_loading
              ? const Center(child: CircularProgressIndicator())
              : content),
    );
  }

  Widget _pieForSelection() {
    final int? n = _selCount == 'todas' ? null : int.tryParse(_selCount);
    final slice = (n == null || n >= _data.length) ? _data : _data.take(n).toList();
    final counts = {
      for (final t in _types) t: slice.where((a) => a.tipo.toLowerCase() == t).length.toDouble()
    };
    final colors = {
      'sismo': Colors.red,
      'panico': Colors.orange,
      'incendio': Colors.deepOrange,
      'infraccion': Colors.blue,
    };

    final sections = _types
        .map((t) => PieChartSectionData(
              value: counts[t]!,
              color: colors[t]!,
              title: counts[t]!.toInt().toString(),
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ))
        .toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _types
              .map((t) => Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 10, height: 10, color: colors[t]),
                    const SizedBox(width: 6),
                    Text('${t[0].toUpperCase()}${t.substring(1)} (${counts[t]!.toInt()})'),
                  ]))
              .toList(),
        ),
      ],
    );
  }
}

// 3era fase
// Top de personas
class TopPersonasSection extends StatefulWidget {
  const TopPersonasSection({super.key});

  @override
  State<TopPersonasSection> createState() => _TopPersonasSectionState();
}

class _TopPersonasSectionState extends State<TopPersonasSection> {
  final _api = ApiClient();
  bool _loading = true;
  String? _error;
  Timer? _timer;
  Map<String, int> _topPersonas = {};

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final alertas = await _api.fetchAlertas(limit: 200);
      if (mounted) {
        // Filtrar solo alertas tipo persona pra no tener todos a la vez
        final personas = alertas.where((a) => a.tipo.toLowerCase() == 'persona').toList();
        // Contador de frecuencia
        final freq = <String, int>{};
        for (final p in personas) {
          freq[p.data] = (freq[p.data] ?? 0) + 1;
        }
        // ordenamiento
        final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        setState(() {
          _topPersonas = Map.fromEntries(sorted.take(10));
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return KpiCard(
      title: 'Top Personas Detectadas en Lista Negra',
      child: _error != null
          ? Column(
              children: [
                Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: _load, child: const Text('Reintentar')),
              ],
            )
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _topPersonas.isEmpty
                  ? const Center(child: Text('No hay datos'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _topPersonas.length,
                      itemBuilder: (ctx, i) {
                        final entry = _topPersonas.entries.elementAt(i);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${entry.value} detecciones'),
                            trailing: const Icon(Icons.person, color: Colors.deepPurple),
                          ),
                        );
                      },
                    ),
    );
  }
}

// Top de armas blancas
class TopArmasSection extends StatefulWidget {
  const TopArmasSection({super.key});

  @override
  State<TopArmasSection> createState() => _TopArmasSectionState();
}

class _TopArmasSectionState extends State<TopArmasSection> {
  final _api = ApiClient();
  bool _loading = true;
  String? _error;
  Timer? _timer;
  Map<String, int> _topArmas = {};

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final alertas = await _api.fetchAlertas(limit: 200);
      if (mounted) {
        // solo tipo arma
        final armas = alertas.where((a) => a.tipo.toLowerCase() == 'arma').toList();
        // frecuencia de cada tipo
        final freq = <String, int>{};
        for (final a in armas) {
          freq[a.data] = (freq[a.data] ?? 0) + 1;
        }
        // Ordenar por mayor frecuencia
        final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        setState(() {
          _topArmas = Map.fromEntries(sorted.take(10));
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  IconData _getArmaIcon(String tipoArma) {
    switch (tipoArma.toLowerCase()) {
      case 'cuchillo':
        return Icons.kitchen;
      case 'navaja':
        return Icons.content_cut;
      case 'machete':
        return Icons.agriculture;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KpiCard(
      title: 'Top Armas Blancas Detectadas',
      child: _error != null
          ? Column(
              children: [
                Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: _load, child: const Text('Reintentar')),
              ],
            )
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _topArmas.isEmpty
                  ? const Center(child: Text('No hay datos'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _topArmas.length,
                      itemBuilder: (ctx, i) {
                        final entry = _topArmas.entries.elementAt(i);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(_getArmaIcon(entry.key), color: Colors.white, size: 20),
                            ),
                            title: Text(
                              '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${entry.value} detecciones'),
                            trailing: Text(
                              '#${i + 1}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// placas
class InfraccionesSection extends StatefulWidget {
  const InfraccionesSection({super.key});

  @override
  State<InfraccionesSection> createState() => _InfraccionesSectionState();
}

class _InfraccionesSectionState extends State<InfraccionesSection> {
  final _api = ApiClient();
  List<Alerta> _data = [];
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final alertas = await _api.fetchAlertas(limit: 200);
      if (mounted) {
        // nomas filtrar por placa
        final infracciones = alertas.where((a) {
          final tipo = a.tipo.trim().toLowerCase();
          return tipo == 'placa';
        }).toList();
        
        setState(() {
          _data = infracciones;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return KpiCard(
      title: 'Infracciones y Placas Detectadas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Infracciones', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      _loading ? '...' : '${_data.length}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _error != null
              ? Column(
                  children: [
                    Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                    TextButton(onPressed: _load, child: const Text('Reintentar')),
                  ],
                )
              : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _data.isEmpty
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay infracciones ni placas registradas'),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _data.length,
                          itemBuilder: (ctx, i) {
                            final infraccion = _data[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.directions_car, color: Colors.white),
                                ),
                                title: Text(
                                  infraccion.data,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text('Hora: ${_formatTime(infraccion.timestamp)}'),
                                trailing: const Icon(Icons.traffic, color: Colors.red),
                              ),
                            );
                          },
                        ),
        ],
      ),
    );
  }
}