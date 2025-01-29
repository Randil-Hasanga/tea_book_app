import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/admin_dashboard.dart';
import 'package:frontend/screens/admin/all_collectors.dart';
import 'package:frontend/screens/admin/all_suppliers.dart';
import 'package:frontend/screens/collector/collect_tea.dart';
import 'package:frontend/screens/collector/collector_dashboard.dart';
import 'package:frontend/screens/collector/deliveries_page.dart';
import 'package:frontend/screens/collector/supplier_page.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/supplier/supplier_dashboard.dart';
import 'package:frontend/screens/supplier/supplier_deliveries.dart';
import 'package:frontend/screens/supplier/supplier_sallaries.dart';
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
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => Login(),
        '/collector-suppliers': (context) => const SupplierPage(),
        '/collector-deliveries': (context) => DeliveriesPage(),
        '/collector_dashboard': (context) => CollectorDashboard(),
        '/collect-tea': (context) => CollectTea(),

        '/supplier-dashboard': (context) => const SupplierDashboard(),
        '/supplier-deliveries': (context) => SupplierDeliveriesPage(),
        '/supplier-salaries': (context) => const SupplierSalariesPage(),

        '/admin_dashboard': (context) => AdminDashboard(),
        '/admin-suppliers': (context) => AllSuppliers(),
        '/admin-collectors': (context) => const AllCollectors(),
        },
      home: const Login(),
    );
  }
}
