import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:frontend/services/user_services.dart';
import 'package:frontend/widgets/rounded_card.dart';
import 'package:get_it/get_it.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  final dio = Dio();
  UserServices? _userServices;

  Response<dynamic>? userDetailsResponse,
      deliveriesResponse,
      suppliersDeliveriesResponse,
      salaryResponse;
  String? supplierName = 'Collector', supplier_id;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    _initializeDashboard(); // Start async logic
  }

  Future<void> _initializeDashboard() async {
    try {
      final userDetailsURL =
          '${_userServices!.base_url}/supplier?user_id=${_userServices!.user_id}';
      final result = await dio.get(userDetailsURL);

      print('User details: ${result.data}');

      supplier_id = result.data['data'][0]['_id'];
      _userServices!.supplier_id = supplier_id;

      final deliveriesURL =
          '${_userServices!.base_url}/delivery/recent/supplier/$supplier_id';
      final deliveries = await dio.get(deliveriesURL);
      print('Deliveries: ${deliveries.data}');

      final now = DateTime.now();
      final int currentMonth = now.month;
      final int currentYear = now.year;

      final supplierDeliveriesURL =
          '${_userServices!.base_url}/delivery/supplier?supplierId=$supplier_id&month=$currentMonth&year=$currentYear';
      final supplierDeliveries = await dio.get(supplierDeliveriesURL);
      print('Supplier deliveries: ${supplierDeliveries.data}');

      final supplierSalaryURL =
          '${_userServices!.base_url}/salary/$supplier_id';
      final supplierSalary = await dio.get(supplierSalaryURL);
      print('supplier salary: ${supplierSalary.data}');

      setState(() {
        userDetailsResponse = result;
        deliveriesResponse = deliveries;
        suppliersDeliveriesResponse = supplierDeliveries;
        salaryResponse = supplierSalary;

        supplierName = userDetailsResponse?.data['data']?[0]['supplier_name'] ??
            'Supplier';
        isLoading = false; // Loading completed
      });
    } catch (e) {
      print('Error fetching collector data: $e');
      setState(() {
        supplierName = 'Error';
        isLoading = false; // Ensure loading stops even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildMainContent(),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF13AA52), Color(0xFF2CA05A)], // Gradient colors
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 241, 255, 242),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      child: const Icon(
                        Icons.eco,
                        size: 100,
                        color: Color(0xFF13AA52),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDashboardCard(
                                title: "Net Weight (Kg)",
                                value: (double.tryParse(salaryResponse
                                                ?.data?['data']['tea_delivered']
                                                .toString() ??
                                            '0') ??
                                        0)
                                    .toStringAsFixed(1),
                                width: 172.5),
                            if (salaryResponse != null &&
                                salaryResponse!.data != null &&
                                salaryResponse!.data['data']['salary'] !=
                                    null) ...{
                              _buildDashboardCard(
                                  title: "Salary (Rs.)",
                                  value: (double.tryParse(salaryResponse
                                                  ?.data?['data']['salary']
                                                  .toString() ??
                                              '0') ??
                                          0)
                                      .toStringAsFixed(1),

                                  // Update this when you have suppliers data
                                  width: 172),
                            } else ...{
                              _buildDashboardCard(
                                  title: "Salary (Rs.)",
                                  value:
                                      '0', // Update this when you have suppliers data
                                  width: 172.5),
                            },
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildRoundedCard(context, '/supplier-salaries',
                                'Salaries', Icons.account_balance_wallet),
                            _buildRoundedCard(context, '/supplier-deliveries',
                                'Deliveries', Icons.archive),
                            _buildDashboardCard(
                                title: "Deliveries",
                                value: suppliersDeliveriesResponse?.data?.length
                                        .toString() ??
                                    '0',
                                width: 110),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (deliveriesResponse != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildRecentDeliveries(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      {required String title,
      required String value,
      required double width,
      double? height}) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 40, color: Color.fromARGB(255, 35, 209, 93)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedCard(
      BuildContext context, String route, String title, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route, arguments: _initializeDashboard);
      },
      child: RoundedCard(
        title: title,
        icon: icon,
        backgroundColor: Colors.white,
        iconBackgroundColor: const Color.fromARGB(255, 227, 255, 227),
        iconColor: const Color.fromARGB(255, 35, 209, 93),
      ),
    );
  }

  Widget _buildRecentDeliveries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Deliveries',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: deliveriesResponse?.data?.length ?? 0,
          itemBuilder: (context, index) {
            final delivery = deliveriesResponse?.data[index];
            final collectorName =
                delivery['collected_by']?['collector_name'] ?? 'Unknown';
            final mobile =
                delivery['collected_by']?['collector_phone']?.toString() ??
                    'N/A';
            final netWeight = delivery['net_weight']?.toString() ?? 'N/A';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                title: Text(
                  collectorName,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800]),
                ),
                subtitle: Text(
                  'Mobile: $mobile',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                ),
                trailing: Text(
                  'Net Weight: $netWeight Kg',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Center(
        child: Text(
          'Hi $supplierName!',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
