import 'package:flutter/material.dart';
import 'package:smart_city/features/home/presentation/pages/control_panel.dart';
import 'package:smart_city/features/home/presentation/pages/feed.dart';
import 'package:smart_city/features/home/presentation/pages/interactive_map.dart';
import 'routes/app_routes.dart';
import 'features/home/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawer App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.pageOne,
      routes: {
        AppRoutes.pageOne: (_) => const ControlPanel(),
        AppRoutes.pageTwo: (_) => const FeedPage(),
        AppRoutes.pageThree: (_) => const InteractiveMap(),
      },
    );
  }
}
