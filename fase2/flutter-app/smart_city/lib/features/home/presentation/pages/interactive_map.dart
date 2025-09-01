import 'package:flutter/material.dart';
import '../widgets/home_drawer.dart';

class InteractiveMap extends StatelessWidget {
  const InteractiveMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa Interactivo")),
      drawer: HomeDrawer(),
      body: Center(child: Text("Contenido del Mapa Interactivo")),
    );
  }
}
