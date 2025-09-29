import 'package:flutter/material.dart';
import '../../../../../routes/app_routes.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Menú de Navegación", style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: const Text("Panel de control"),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.pageOne);
            },
          ),
          ListTile(
            title: const Text("Feed de notificaciones"),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.pageTwo);
            },
          ),
          ListTile(
            title: const Text("Mapa interactivo"),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.pageThree);
            },
          ),
        ],
      ),
    );
  }
}
