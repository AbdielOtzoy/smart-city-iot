import 'package:flutter/material.dart';
import '../widgets/home_drawer.dart';
import 'dart:async';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({super.key});

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> with TickerProviderStateMixin {
  Color busColor = Colors.green;
  
  // Animaciones para el bus verde
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _stationTimer;
  
  // Animaciones para el bus azul
  late AnimationController _blueAnimationController;
  late Animation<double> _blueAnimation;
  Timer? _blueStationTimer;
  
  // Posiciones del bus verde
  double busLeft = 85;
  double busBottom = 175;
  
  // Posiciones del bus azul
  double blueBusLeft = 155;
  double blueBusBottom = 295;
  
  // Definir las rutas con waypoints para el bus verde
  List<Map<String, double>> route = [
    {'left': 85, 'bottom': 175}, // Posición inicial (cerca estación verde mercado)
    {'left': 162, 'bottom': 175}, // Hacia la derecha
    {'left': 162, 'bottom': 560}, // Hacia arriba (top: 25 = bottom: 535 en contenedor de 600)
    {'left': 303, 'bottom': 560}, // Hacia la derecha
    {'left': 303, 'bottom': 485}, // Hacia abajo (llega a la estacion verde superior, se detiene 5s)
    {'left': 303, 'bottom': 400}, // Hacia abajo (top: 160 = bottom: 400)
    {'left': 1, 'bottom': 400}, // Regreso hacia la izquierda
    {'left': 1, 'bottom': 175}, // Hacia abajo
    {'left': 85, 'bottom': 175}, // Hacia la derecha (regreso a la estación verde mercado, se detiene 5s)
  ];
  
  // Definir las rutas con waypoints para el bus azul
  List<Map<String, double>> blueRoute = [
    {'left': 155, 'bottom': 295}, // Posición inicial (en estacion)
    {'left': 155, 'bottom': 400}, // Hacia arriba
    {'left': 1, 'bottom': 400}, // Hacia la izquierda
    {'left': 1, 'bottom': 175}, // Hacia abajo
    {'left': 303, 'bottom': 175}, // Al fondo a la derecha
    {'left': 303, 'bottom': 10}, // Hacia abajo
    {'left': 155, 'bottom': 10}, // Hacia la izquierda al centro
    {'left': 155, 'bottom': 120}, // Hacia arriba (llega a la estacion)
    {'left': 155, 'bottom': 295}, // Regreso a posición inicial (regresa a la estación, se detiene 5s)
  ];
  
  int currentRouteIndex = 0;
  bool isAtStation = false;
  
  int blueCurrentRouteIndex = 0;
  bool blueIsAtStation = false;
  
  // Control de animación
  bool isAnimationRunning = false;
  
  // Variables para guardar el progreso de animación cuando se pausa
  double savedAnimationProgress = 0.0;
  double savedBlueAnimationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Configuración para el bus verde
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2200), // Ajustado para completar ciclo en ~10s (8 segmentos)
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animation.addListener(() {
      setState(() {
        // Interpolar entre posición actual y siguiente para el bus verde
        if (currentRouteIndex < route.length - 1) {
          double startLeft = route[currentRouteIndex]['left']!;
          double endLeft = route[currentRouteIndex + 1]['left']!;
          double startBottom = route[currentRouteIndex]['bottom']!;
          double endBottom = route[currentRouteIndex + 1]['bottom']!;
          
          busLeft = startLeft + (endLeft - startLeft) * _animation.value;
          busBottom = startBottom + (endBottom - startBottom) * _animation.value;
        }
      });
    });
    
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        currentRouteIndex = (currentRouteIndex + 1) % route.length;
        
        // Verificar si llegamos a una estación verde
        if (_isAtGreenStation()) {
          _stopAtStation();
        } else {
          _continueMovement();
        }
      }
    });

    // Configuración para el bus azul
    _blueAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2200), // Mismo timing que el bus verde
      vsync: this,
    );
    
    _blueAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _blueAnimationController, curve: Curves.easeInOut),
    );
    
    _blueAnimation.addListener(() {
      setState(() {
        // Interpolar entre posición actual y siguiente para el bus azul
        if (blueCurrentRouteIndex < blueRoute.length - 1) {
          double startLeft = blueRoute[blueCurrentRouteIndex]['left']!;
          double endLeft = blueRoute[blueCurrentRouteIndex + 1]['left']!;
          double startBottom = blueRoute[blueCurrentRouteIndex]['bottom']!;
          double endBottom = blueRoute[blueCurrentRouteIndex + 1]['bottom']!;
          
          blueBusLeft = startLeft + (endLeft - startLeft) * _blueAnimation.value;
          blueBusBottom = startBottom + (endBottom - startBottom) * _blueAnimation.value;
        }
      });
    });
    
    _blueAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        blueCurrentRouteIndex = (blueCurrentRouteIndex + 1) % blueRoute.length;
        
        // Verificar si llegamos a una estación azul
        if (_isAtBlueStation()) {
          _stopBlueAtStation();
        } else {
          _continueBlueMovement();
        }
      }
    });
    
    // Las animaciones no se inician automáticamente, esperan el tap del usuario
  }

  bool _isAtGreenStation() {
    // Estación verde superior (arriba derecha) - Positioned: top: 60, right: 20
    // En coordenadas bottom sería: bottom = 600-60-30 = 510 (aproximadamente)
    // En coordenadas left sería: left = 350-20-15 = 315 (aproximadamente)
    if ((busLeft > 295 && busLeft < 305) && (busBottom > 480 && busBottom < 490)) {
      return true;
    }
    // Estación verde mercado central - Positioned: bottom: 160, left: 70
    if ((busLeft > 80 && busLeft < 90) && (busBottom > 170 && busBottom < 180)) {
      return true;
    }
    return false;
  }

  void _stopAtStation() {
    isAtStation = true;
    _stationTimer = Timer(const Duration(seconds: 5), () {
      isAtStation = false;
      _continueMovement();
    });
  }

  void _continueMovement() {
    if (!isAtStation && mounted && isAnimationRunning) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  // Métodos para el bus azul
  bool _isAtBlueStation() {
    // Estación azul centro izquierda - Positioned: top: 260, left: 140
    // El bus llega a esta estación en la posición 7: {'left': 155, 'bottom': 120} (llega a la estacion)
    if ((blueBusLeft > 150 && blueBusLeft < 160) && (blueBusBottom > 115 && blueBusBottom < 125)) {
      return true;
    }
    // Estación azul inicial - Posición inicial donde inicia el bus: {'left': 155, 'bottom': 275} (en estacion)
    if ((blueBusLeft > 150 && blueBusLeft < 160) && (blueBusBottom > 270 && blueBusBottom < 280)) {
      return true;
    }
    return false;
  }

  void _stopBlueAtStation() {
    blueIsAtStation = true;
    _blueStationTimer = Timer(const Duration(seconds: 5), () {
      blueIsAtStation = false;
      _continueBlueMovement();
    });
  }

  void _continueBlueMovement() {
    if (!blueIsAtStation && mounted && isAnimationRunning) {
      _blueAnimationController.reset();
      _blueAnimationController.forward();
    }
  }

  // Métodos para reanudar animaciones desde donde se pausaron
  void _resumeMovement() {
    if (!isAtStation && mounted && isAnimationRunning) {
      if (savedAnimationProgress > 0.0 && savedAnimationProgress < 1.0) {
        // Reanudar desde donde se quedó
        _animationController.value = savedAnimationProgress;
        _animationController.forward();
        savedAnimationProgress = 0.0; // Reset para próxima vez
      } else {
        // Si estaba al final o inicio, comenzar normalmente
        _continueMovement();
      }
    }
  }

  void _resumeBlueMovement() {
    if (!blueIsAtStation && mounted && isAnimationRunning) {
      if (savedBlueAnimationProgress > 0.0 && savedBlueAnimationProgress < 1.0) {
        // Reanudar desde donde se quedó
        _blueAnimationController.value = savedBlueAnimationProgress;
        _blueAnimationController.forward();
        savedBlueAnimationProgress = 0.0; // Reset para próxima vez
      } else {
        // Si estaba al final o inicio, comenzar normalmente
        _continueBlueMovement();
      }
    }
  }

  // Método para alternar el estado de la animación
  void _toggleAnimation() {
    setState(() {
      isAnimationRunning = !isAnimationRunning;
      
      if (isAnimationRunning) {
        // Iniciar ambas animaciones desde donde se quedaron
        _resumeMovement();
        _resumeBlueMovement();
      } else {
        // Guardar el progreso actual antes de detener
        savedAnimationProgress = _animationController.value;
        savedBlueAnimationProgress = _blueAnimationController.value;
        
        // Detener ambas animaciones
        _animationController.stop();
        _blueAnimationController.stop();
        
        // Cancelar timers de estación si están activos
        _stationTimer?.cancel();
        _blueStationTimer?.cancel();
        
        // Resetear estados de estación
        isAtStation = false;
        blueIsAtStation = false;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stationTimer?.cancel();
    _blueAnimationController.dispose();
    _blueStationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa Interactivo")),
      drawer: HomeDrawer(),
      body: GestureDetector(
        onTap: _toggleAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: 350,
                height: 600,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    // Fila superior de cuadras
                    Positioned(
                      top: 40,
                      left: 40,
                      child: _buildBlock("BIBLIOTECA\nNACIONAL"),
                    ),
                    Positioned(
                      top: 40,
                      right: 40,
                      child: _buildBlock(""),
                    ),
                    
                    // Estación de bus verde (arriba derecha)
                    Positioned(
                      top: 60,
                      right: 20,
                      child: _buildBusStation(Colors.green),
                    ),
                    
                    // Fila central de cuadras
                    Positioned(
                      top: 230,
                      left: 40,
                      child: _buildBlock(""),
                    ),
                    Positioned(
                      top: 230,
                      right: 40,
                      child: _buildBlock("PALACIO\nNACIONAL"),
                    ),
                    
                    // Estación de bus azul (centro izquierda)
                    Positioned(
                      top: 260,
                      left: 140,
                      child: _buildBusStation(Colors.blue),
                    ),
                    
                    // Fila inferior de cuadras
                    Positioned(
                      bottom: 40,
                      left: 40,
                      child: _buildBlock("MERCADO\nCENTRAL"),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 40,
                      child: _buildBlock(""),
                    ),
                    
                    // Estación de bus verde (arriba del mercado central)
                    Positioned(
                      bottom: 160,
                      left: 70,
                      child: _buildBusStation(Colors.green),
                    ),
                    
                    // Estación de bus azul (abajo derecha)
                    Positioned(
                      bottom: 90,
                      right: 140,
                      child: _buildBusStation(Colors.blue),
                    ),
                    
                    // Figurita de bus verde
                    Positioned(
                      bottom: busBottom,
                      left: busLeft,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            busColor = busColor == Colors.green ? Colors.blue : Colors.green;
                          });
                        },
                        child: _buildBusFigure(busColor),
                      ),
                    ),
                    
                    // Figurita de bus azul
                    Positioned(
                      bottom: blueBusBottom,
                      left: blueBusLeft,
                      child: GestureDetector(
                        onTap: () {
                          // Bus azul no cambia de color, permanece azul
                        },
                        child: _buildBusFigure(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlock(String label) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBusStation(Color color) {
    return Container(
      width: 15,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  Widget _buildBusFigure(Color color) {
    return Container(
      width: 40,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Stack(
        children: [
          // Ventanas del bus
          Positioned(
            left: 4,
            top: 3,
            child: Container(
              width: 6,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 0.5),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 3,
            child: Container(
              width: 6,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 0.5),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 3,
            child: Container(
              width: 6,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 0.5),
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 3,
            child: Container(
              width: 6,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 0.5),
              ),
            ),
          ),
          // Ruedas del bus
          Positioned(
            left: 6,
            bottom: -2,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 28,
            bottom: -2,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
