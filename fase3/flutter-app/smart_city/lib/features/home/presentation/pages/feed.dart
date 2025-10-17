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
  Map<String, dynamic> data = {'alertas': []};
  bool isLoading = true;
  String? error;
  late final baseUrl;
  late final realtimeTimer;
  DateTime? _lastUpdate;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    baseUrl = 'https://fastapi-api-1nhl.onrender.com';
    
    // Carga inicial de datos en tiempo real
    fetchRealtimeData();
    
    // Actualiza todos los datos cada segundo
    realtimeTimer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      fetchRealtimeData();
    });
  }

  @override
  void dispose() {
    realtimeTimer.cancel();
    super.dispose();
  }

  Future<void> fetchRealtimeData() async {
    if (!_isUpdating) {
      setState(() {
        _isUpdating = true;
      });
    }

    try {
      final alertasRes = await http.get(Uri.parse('$baseUrl/alertas/9'));
      final newAlertas = jsonDecode(alertasRes.body);

      setState(() {
        data = {
          'alertas': newAlertas,
        };
        isLoading = false;
        error = null;
        _lastUpdate = DateTime.now();
        _isUpdating = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        _isUpdating = false;
      });
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} "
           "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // Opciones principales para filtrar
    final tiposSet = ['PERSONA', 'ARMA', 'INFRACCION'];

    return Scaffold(
      appBar: AppBar(title: Text("Alertas en Tiempo Real")),
      drawer: HomeDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con indicadores de actualización
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                                                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alertas en Tiempo Real', 
                                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                // Indicador de actualización como en tu imagen
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _lastUpdate != null 
                                            ? 'Actualizado: ${_formatTimestamp(_lastUpdate!)}'
                                            : 'Conectando...',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (_isUpdating)
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _isUpdating ? 'LIVE' : 'ACTUALIZADO',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Filtros
                        if ((data['alertas'] as List<dynamic>? ?? []).isNotEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Filtrar por tipo:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      DropdownButton<String>(
                                        value: selectedTipo,
                                        hint: Text('Selecciona tipo'),
                                        items: tiposSet.map((tipo) => DropdownMenuItem<String>(
                                          value: tipo,
                                          child: Text(tipo.toUpperCase()),
                                        )).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTipo = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  if (selectedTipo != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedTipo = null;
                                          });
                                        },
                                        child: Text('Limpiar filtro'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Lista de alertas
                        if ((data['alertas'] as List<dynamic>? ?? []).isEmpty)
                          Card(
                            color: Colors.grey[100],
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.notifications_none, 
                                         size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('No hay alertas en este momento',
                                         style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                                    Text('Actualizando cada segundo...',
                                         style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...((data['alertas'] as List<dynamic>? ?? [])
                              .where((a) {
                                final rawType = ((a['tipo'] ?? a['clase'])?.toString() ?? '').toUpperCase();
                                if (selectedTipo == null) return true;
                                switch (selectedTipo) {
                                  case 'PERSONA':
                                    return rawType == 'PERSONA';
                                  case 'ARMA':
                                    return rawType == 'ARMA_BLANCA' || rawType == 'ARMA_FUEGO';
                                  case 'INFRACCION':
                                    return rawType == 'PLACAS' || rawType == 'INFRACCION';
                                  default:
                                    return false;
                                }
                              })
                              .map((a) {
                                // ...existing code...
                                final rawType = ((a['tipo'] ?? a['clase'])?.toString() ?? '').toUpperCase();
                                Color cardColor;
                                Color iconColor;
                                Color textColor = Colors.black;
                                Color subtitleColor = Colors.grey[700]!;
                                IconData alertIcon;
                                String titleText = rawType;
                                String line1 = 'Detalle: ${a['data'] ?? a['data'] ?? 'N/A'}';
                                String line2 = 'Fecha: ${a['timestamp'] ?? a['timestamp'] ?? 'N/A'}';

                                final isBlacklisted = (a['lista_negra'] == true) ||
                                    (a['blacklist'] == true) ||
                                    (a['blacklisted'] == true) ||
                                    ((a['data'] is String) && (a['data'].toString().toLowerCase().contains('lista') || a['data'].toString().toLowerCase().contains('black')));

                                switch (rawType) {
                                  case 'ARMA_BLANCA':
                                  case 'ARMA_FUEGO':
                                    cardColor = const Color.fromARGB(240, 187, 82, 98);
                                    iconColor = Colors.red;
                                    textColor = Colors.white;
                                    subtitleColor = Colors.white70;
                                    alertIcon = Icons.security;
                                    titleText = (a['tipo']?.toString().toUpperCase() ?? 'ARMA');
                                    line1 = 'Subtipo: ${a['subtipo'] ?? 'N/A'}';
                                    line2 = 'Fecha: ${a['timestamp'] ?? 'N/A'}';
                                    break;
                                  case 'PERSONA':
                                    cardColor = Colors.deepPurple[300]!;
                                    iconColor = Colors.purple;
                                    alertIcon = Icons.person;
                                    titleText = isBlacklisted ? 'PERSONA (LISTA NEGRA)' : 'PERSONA';
                                    textColor = Colors.white;
                                    subtitleColor = Colors.white70;
                                    line1 = 'Nombre: ${a['data'] ?? 'N/A'}';
                                    line2 = 'Fecha: ${a['timestamp'] ?? 'N/A'}';
                                    break;
                                  case 'PLACAS':
                                    cardColor = Colors.teal.shade200;
                                    iconColor = Colors.teal.shade900;
                                    alertIcon = Icons.directions_car;
                                    titleText = 'INFRACCIÓN - PLACA';
                                    textColor = Colors.black;
                                    subtitleColor = Colors.grey.shade800;
                                    line1 = 'Placa: ${a['placa_texto'] ?? a['placa'] ?? 'N/A'}';
                                    line2 = 'Fecha: ${a['timestamp'] ?? 'N/A'}';
                                    break;
                                  case 'SISMO':
                                    cardColor = const Color.fromARGB(240, 187, 82, 98);
                                    iconColor = Colors.red;
                                    textColor = Colors.white;
                                    subtitleColor = Colors.white70;
                                    alertIcon = Icons.vibration;
                                    break;
                                  case 'PANICO':
                                    cardColor = Colors.yellow[100]!;
                                    iconColor = Colors.orange;
                                    alertIcon = Icons.warning;
                                    break;
                                  case 'INCENDIO':
                                    cardColor = Colors.orange[100]!;
                                    iconColor = Colors.deepOrange;
                                    alertIcon = Icons.local_fire_department;
                                    break;
                                  case 'INFRACCION':
                                    cardColor = Colors.blue[100]!;
                                    iconColor = Colors.blue;
                                    alertIcon = Icons.gavel;
                                    break;
                                  default:
                                    cardColor = const Color.fromARGB(255, 124, 152, 174);
                                    iconColor = const Color.fromARGB(255, 1, 33, 94);
                                    alertIcon = Icons.notification_important;
                                }

                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: cardColor,
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: iconColor.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(alertIcon, color: iconColor, size: 24),
                                    ),
                                    title: Text(
                                      titleText,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(line1, style: TextStyle(fontSize: 14, color: textColor)),
                                        Text(line2, style: TextStyle(fontSize: 12, color: subtitleColor)),
                                      ],
                                    ),
                                    trailing: Icon(Icons.chevron_right, color: iconColor),
                                  ),
                                );
                              }))
                      ],
                    ),
                  ),
                ),
    );
  }
}