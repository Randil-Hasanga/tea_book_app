import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/services/user_services.dart';
import 'package:frontend/widgets/rounded_card.dart';
import 'package:get_it/get_it.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  final dio = Dio();
  UserServices? _userServices;

  Response<dynamic>? userDetailsResponse,
      deliveriesResponse,
      suppliersResponse,
      collecotrDeliveriesResponse;
  String? collectorName = 'Collector', collector_id, role;
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
          '${_userServices!.base_url}/collector?user_id=${_userServices!.user_id}';
      final result = await dio.get(userDetailsURL);

      collector_id = result.data['data'][0]['_id'];
      role = _userServices!.role;
      print('user role :::::::::::: ${role}');
      _userServices!.collector_id = collector_id;

      final deliveriesURL =
          '${_userServices!.base_url}/delivery/recent/$collector_id';
      final deliveries = await dio.get(deliveriesURL);

      final suppliersUrl =
          '${_userServices!.base_url}/supplier/createdBy/$collector_id';
      final suppliers = await dio.get(suppliersUrl);

      final now = DateTime.now();
      final int currentMonth = now.month;
      final int currentYear = now.year;

      final collecotrDeliveriesURL =
          '${_userServices!.base_url}/delivery?collectorId=$collector_id&month=$currentMonth&year=$currentYear';
      final collectorDeliveries = await dio.get(collecotrDeliveriesURL);

      setState(() {
        userDetailsResponse = result;
        deliveriesResponse = deliveries;
        suppliersResponse = suppliers;
        collecotrDeliveriesResponse = collectorDeliveries;

        collectorName = userDetailsResponse?.data['data']?[0]
                ['collector_name'] ??
            'Collector';
        isLoading = false; // Loading completed
      });
    } catch (e) {
      print('Error fetching collector data: $e');
      setState(() {
        collectorName = 'Error';
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

  /// Builds the background with two containers for a modern look
  Widget _buildBackground() {
    return Stack(
      children: [
        // Full-screen background container
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF13AA52), Color(0xFF2CA05A)], // Gradient colors
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Second container with rounded corners
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

  /// Builds the main content of the dashboard
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              height: 120,
                              width: 235,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("This Month Deliveries"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        collecotrDeliveriesResponse
                                                ?.data?.length
                                                .toString() ??
                                            '0',
                                        style: const TextStyle(
                                            fontSize: 50,
                                            color: Color.fromARGB(
                                                255, 35, 209, 93)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              height: 120,
                              width: 110,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Suppliers"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        suppliersResponse?.data['data']['count']
                                                ?.toString() ??
                                            '0', // Safely accessing the count
                                        style: const TextStyle(
                                          fontSize: 50,
                                          color:
                                              Color.fromARGB(255, 35, 209, 93),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/collector-suppliers',
                                    arguments: _initializeDashboard);
                              },
                              child: const RoundedCard(
                                title: 'Suppliers',
                                icon: Icons.people,
                                backgroundColor: Colors.white,
                                iconBackgroundColor:
                                    Color.fromARGB(255, 227, 255, 227),
                                iconColor: Color.fromARGB(255, 35, 209, 93),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/collector-deliveries');
                              },
                              child: const RoundedCard(
                                title: 'Deliveries',
                                icon: Icons.archive,
                                backgroundColor: Colors.white,
                                iconBackgroundColor:
                                    Color.fromARGB(255, 227, 255, 227),
                                iconColor: Color.fromARGB(255, 35, 209, 93),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/collect-tea',
                                    arguments: _initializeDashboard);
                                // Add your button action here
                              }, // Ripple effect color
                              child: const RoundedCard(
                                title: 'Collect Tea',
                                icon: Icons.add,
                                backgroundColor: Colors.white,
                                iconBackgroundColor:
                                    Color.fromARGB(255, 227, 255, 227),
                                iconColor: Color.fromARGB(255, 35, 209, 93),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // deliveries list
                        if (deliveriesResponse != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recent Deliveries',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      deliveriesResponse?.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final delivery =
                                        deliveriesResponse?.data[index];
                                    final supplierName = delivery['supplied_by']
                                            ?['supplier_name'] ??
                                        'Unknown';
                                    final mobile = delivery['supplied_by']
                                                ?['supplier_phone']
                                            ?.toString() ??
                                        'N/A';
                                    final netWeight =
                                        delivery['net_weight']?.toString() ??
                                            'N/A';

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(4, 4),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 2.0), // Add padding
                                        tileColor: Colors
                                            .white, // Background color for each tile
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12.0), // Rounded corners
                                        ),
                                        title: Text(
                                          supplierName,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[
                                                800], // Supplier name color
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Mobile: $mobile',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors
                                                .grey[700], // Subtitle color
                                          ),
                                        ),
                                        trailing: Text(
                                          'Net Weight: $netWeight Kg',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .blue[600], // Net weight color
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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

  Widget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Center(
        child: Text(
          'Hi $collectorName !',
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
