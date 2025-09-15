import 'package:flutter/material.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const EcoSustainApp());
}

class EcoSustainApp extends StatelessWidget {
  const EcoSustainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
 