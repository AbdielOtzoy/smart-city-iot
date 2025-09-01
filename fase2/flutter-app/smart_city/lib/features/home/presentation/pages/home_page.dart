import 'package:flutter/material.dart';
import '../widgets/home_drawer.dart';
import 'control_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menú Principal")),
      drawer: HomeDrawer(),
      body: ControlPanel(), // por defecto
    );
  }
}
