import 'package:flutter/material.dart';
import '../widgets/home_drawer.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel de Control")),
      drawer: HomeDrawer(),
      body: Center(child: Text("Contenido del Panel de Control")),
    );
  }
}
