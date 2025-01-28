import 'package:flutter/material.dart';
import 'package:frontend/screens/collector/collector_dashboard.dart';
import 'package:frontend/screens/collector/supplier_page.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/services/user_services.dart';
import 'package:get_it/get_it.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.instance.registerSingleton<UserServices>(
    UserServices(),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 183, 110)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/suppliers': (context) => const SupplierPage(),
        '/collector_dashboard': (context) => CollectorDashboard()
        },
      home: const Login(),
    );
  }
}
