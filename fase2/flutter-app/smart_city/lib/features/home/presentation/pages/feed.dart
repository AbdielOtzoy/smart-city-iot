import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/home_drawer.dart';

String? selectedTipo;

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  Map<String, dynamic> data = {'alertas': [], 'trafico': [], 'ambiente': []};
  bool isLoading = true;
  String? error;
  late final baseUrl;
  late final alertasTimer;
  late final traficoAmbienteTimer;

  @override
  void initState() {
    super.initState();
    baseUrl = 'https://fastapi-api-1nhl.onrender.com';
    fetchAllData();
    // Actualiza alertas cada 20 segundos
    alertasTimer = Stream.periodic(const Duration(seconds: 20)).listen((_) {
      fetchAlertas();
    });
    // Actualiza tráfico y ambiente cada segundo
    traficoAmbienteTimer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      fetchTraficoAmbiente();
    });
  }

  @override
  void dispose() {
    alertasTimer.cancel();
    traficoAmbienteTimer.cancel();
    super.dispose();
  }

  Future<void> fetchAllData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final alertasRes = await http.get(Uri.parse('$baseUrl/alertas'));
      final traficoRes = await http.get(Uri.parse('$baseUrl/trafico'));
      final ambienteRes = await http.get(Uri.parse('$baseUrl/ambiente'));
      final newAlertas = jsonDecode(alertasRes.body);
      final newTrafico = jsonDecode(traficoRes.body);
      final newAmbiente = jsonDecode(ambienteRes.body);

      setState(() {
        data = {
          'alertas': newAlertas,
          'trafico': newTrafico,
          'ambiente': newAmbiente,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchAlertas() async {
    try {
      final alertasRes = await http.get(Uri.parse('$baseUrl/alertas'));
      final newAlertas = jsonDecode(alertasRes.body);
      bool hasNew = false;
      if ((newAlertas is List && newAlertas.isNotEmpty) && (data['alertas'] is List && data['alertas'].isNotEmpty)) {
        if (newAlertas[0]['id'] != data['alertas'][0]['id']) hasNew = true;
      } else if (newAlertas.isNotEmpty) {
        hasNew = true;
      }
      if (hasNew) {
        setState(() {
          data['alertas'] = newAlertas;
        });
      }
    } catch (_) {}
  }

  Future<void> fetchTraficoAmbiente() async {
    try {
      final traficoRes = await http.get(Uri.parse('$baseUrl/trafico'));
      final ambienteRes = await http.get(Uri.parse('$baseUrl/ambiente'));
      final newTrafico = jsonDecode(traficoRes.body);
      final newAmbiente = jsonDecode(ambienteRes.body);
      bool traficoNew = false;
      bool ambienteNew = false;
      if ((newTrafico is List && newTrafico.isNotEmpty) && (data['trafico'] is List && data['trafico'].isNotEmpty)) {
        if (newTrafico[0]['timestamp'] != data['trafico'][0]['timestamp']) traficoNew = true;
      } else if (newTrafico.isNotEmpty) {
        traficoNew = true;
      }
      if ((newAmbiente is List && newAmbiente.isNotEmpty) && (data['ambiente'] is List && data['ambiente'].isNotEmpty)) {
        if (newAmbiente[0]['timestamp'] != data['ambiente'][0]['timestamp']) ambienteNew = true;
      } else if (newAmbiente.isNotEmpty) {
        ambienteNew = true;
      }
      if (traficoNew || ambienteNew) {
        setState(() {
          if (traficoNew) data['trafico'] = newTrafico;
          if (ambienteNew) data['ambiente'] = newAmbiente;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificaciones por alertas")),
      drawer: HomeDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alertas recientes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Filtrar por tipo:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: selectedTipo,
                                hint: Text('Selecciona tipo'),
                                items: [
                                  ...((data['alertas'] as List<dynamic>? ?? [])
                                    .map((a) => a['tipo']?.toString() ?? '')
                                    .toSet()
                                    .map((tipo) => DropdownMenuItem<String>(
                                          value: tipo,
                                          child: Text(tipo.toUpperCase()),
                                        )))
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedTipo = value;
                                  });
                                },
                              ),
                              if (selectedTipo != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedTipo = null;
                                    });
                                  },
                                  child: Text('Limpiar filtro'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...((data['alertas'] as List<dynamic>? ?? [])
                              .where((a) => selectedTipo == null || a['tipo'] == selectedTipo)
                              .map((a) {
                                Color cardColor;
                                Color iconColor;
                                Color textColor = Colors.black;
                                Color subtitleColor = Colors.grey[700]!;
                                switch (a['tipo']?.toString().toUpperCase()) {
                                  case 'SISMO':
                                    cardColor = const Color.fromARGB(240, 187, 82, 98);
                                    iconColor = Colors.red;
                                    textColor = Colors.white;
                                    subtitleColor = Colors.white;
                                    break;
                                  case 'PANICO':
                                    cardColor = Colors.yellow[100]!;
                                    iconColor = Colors.orange;
                                    break;
                                  case 'INCENDIO':
                                    cardColor = Colors.orange[100]!;
                                    iconColor = Colors.deepOrange;
                                    break;
                                  case 'INFRACCION':
                                    cardColor = Colors.blue[100]!;
                                    iconColor = Colors.blue;
                                    break;
                                  default:
                                    cardColor = const Color.fromARGB(255, 124, 152, 174);
                                    iconColor = const Color.fromARGB(255, 1, 33, 94);
                                }
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: cardColor,
                                  child: ListTile(
                                    leading: Icon(Icons.warning, color: iconColor, size: 32),
                                    title: Text(
                                      '${a['tipo']?.toUpperCase() ?? 'Alerta'}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Nivel o zona: ${a['data']}', style: TextStyle(fontSize: 16, color: textColor)),
                                        Text('Fecha: ${a['timestamp']}', style: TextStyle(fontSize: 14, color: subtitleColor)),
                                      ],
                                    ),
                                  ),
                                );
                              })),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('Tráfico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    ...((data['trafico'] as List<dynamic>? ?? []).map((t) {
                      final semaforos = t['semaforos'] as List? ?? [];
                      return Column(
                        children: semaforos.map<Widget>((s) {
                          Color cardColor;
                          String colorStr = (s is Map && s.containsKey('color')) ? s['color'].toString().toLowerCase() : s.toString().toLowerCase();
                          switch (colorStr) {
                            case 'rojo':
                              cardColor = Colors.red[300]!;
                              break;
                            case 'amarillo':
                              cardColor = Colors.yellow[300]!;
                              break;
                            case 'verde':
                              cardColor = Colors.green[300]!;
                              break;
                            default:
                              cardColor = Colors.grey[300]!;
                          }
                          String colorDisplay = colorStr.isNotEmpty ? colorStr[0].toUpperCase() + colorStr.substring(1) : 'Desconocido';
                          return Card(
                            color: cardColor,
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            child: ListTile(
                              leading: Icon(Icons.traffic, color: Colors.black),
                              title: Text('Color: $colorDisplay', style: TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Text('Fecha: ${t['timestamp']}', style: TextStyle(fontSize: 12)),
                            ),
                          );
                        }).toList(),
                      );
                    })),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('Ambiente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    ...((data['ambiente'] as List<dynamic>? ?? []).map((am) {
                      final sensores = am['mq_sensors'] as List? ?? [];
                      return Column(
                        children: sensores.map<Widget>((s) {
                          Color cardColor;
                          String colorStr = (s is Map && s.containsKey('color')) ? s['color'].toString().toLowerCase() : '';
                          switch (colorStr) {
                            case 'rojo':
                              cardColor = Colors.red[200]!;
                              break;
                            case 'amarillo':
                              cardColor = Colors.yellow[200]!;
                              break;
                            case 'verde':
                              cardColor = Colors.green[200]!;
                              break;
                            default:
                              cardColor = Colors.grey[200]!;
                          }
                          String nivel = s is Map && s.containsKey('nivel') ? s['nivel'].toString() : 'Desconocido';
                          String id = s is Map && s.containsKey('id') ? s['id'].toString() : 'Desconocido';
                          return Card(
                            color: cardColor,
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            child: ListTile(
                              leading: Icon(Icons.sensors, color: Colors.black),
                              title: Text('Sensor\nID: $id', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Nivel: $nivel'),
                              trailing: Text('Fecha: ${am['timestamp']}', style: TextStyle(fontSize: 12)),
                            ),
                          );
                        }).toList(),
                      );
                    })),
                  ],
                ),
    );
  }
}
