import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/home_drawer.dart';
import '../../../home/data/api_client.dart';
import '../../data/structs.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
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
  static const double mqMax = 1023;
  static const String mqUnits = 'ppm';

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
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
  final String label;
  final double? value;
  final double min;
  final double max;
  final String units;
  final double strokeWidth;

  const SemicircleGauge({
    super.key,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 1023,
    this.units = '',
    this.strokeWidth = 14,
  });

  Color _colorFor(double ratio) {
    if (ratio <= 1 / 3) return Colors.green;
    if (ratio <= 2 / 3) return Colors.amber;
    return Colors.red;
  }
  // widget pa el semicirculo
  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && max > min;
    final ratio = hasValue ? ((value! - min) / (max - min)).clamp(0.0, 1.0) : 0.0;
    final color = _colorFor(ratio);

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
      final res = await _api.fetchAlertas(limit: 300);
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
