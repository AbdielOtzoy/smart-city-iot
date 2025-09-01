import 'package:flutter/material.dart';
import '../widgets/home_drawer.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Página de Noticias")),
      drawer: HomeDrawer(),
      body: Center(child: Text("Contenido de la Página de Noticias")),
    );
  }
}
