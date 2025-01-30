import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/services/user_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  final dio = Dio();
  UserServices? _userServices;
  String? _collectorId;
  List<Map<String, dynamic>> deliveries = [];
  List<Map<String, dynamic>> filteredDeliveries = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
   TextScaler? _textScaleFactor;
  // Initial month and year values
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  
  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    _initializeDashboard();
    _searchController.addListener(_filterSuppliers);
  }

  // Method to initialize the dashboard with data for the selected month and year
  Future<void> _initializeDashboard({int? month, int? year}) async {
  try {
    setState(() {
      _collectorId = _userServices!.collector_id;
    });
    print('collector id: $_collectorId');
    print(year);

    final now = DateTime.now();
    final int currentMonth = month ?? now.month;
    final int currentYear = year ?? now.year;

    final deliveriesURL =
        '${_userServices!.base_url}/delivery?collectorId=$_collectorId&month=$currentMonth&year=$currentYear';

    final response = await dio.get(deliveriesURL);

    final data = response.data;

    if (response.statusCode == 404) {
      print("No deliveries found for this collector");
      setState(() {
        deliveries = [];
        filteredDeliveries = [];
      });
    } else if (data is Map<String, dynamic> && data['message'] != null) {
      // Handle the case where there is a message indicating no deliveries
      print("No deliveries found for this collector");
      setState(() {
        deliveries = [];
        filteredDeliveries = [];
      });
    } else {
      // Assuming the response data is a list of deliveries
      final List<Map<String, dynamic>> deliveryList =
          List<Map<String, dynamic>>.from(data);

      // Sort deliveries from latest to oldest based on createdAt
      deliveryList.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));

      setState(() {
        deliveries = deliveryList;
        filteredDeliveries = deliveries;
      });
    }
  } on DioException catch (e) {
    print('Error fetching data: ${e.message}');
    if (e.response?.statusCode == 404) {
      print("No deliveries found for this collector (404)");
      setState(() {
        deliveries = [];
        filteredDeliveries = [];
      });
    } else {
      print("Unexpected error: ${e.response?.statusCode}");
      setState(() {
        deliveries = [];
        filteredDeliveries = [];
      });
    }
  } catch (e) {
    print('Unexpected error: $e');
    setState(() {
      deliveries = [];
      filteredDeliveries = [];
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _filterSuppliers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDeliveries = deliveries.where((delivery) {
        final name = delivery['supplied_by']['supplier_name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Widget _buildSupplierList() {
    if (filteredDeliveries.isEmpty) {
      return const Center(child: Text('No deliveries found for this collector'));
    }

    return ListView.builder(
      itemCount: filteredDeliveries.length,
      itemBuilder: (context, index) {
        final delivery = filteredDeliveries[index];
        final supplier = delivery['supplied_by'];
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(delivery['createdAt']));

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: Text(
                    supplier['supplier_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Phone: ${supplier['supplier_phone']}'),
                      Text('Net Weight: ${delivery['net_weight']} kg'),
                      Text('Date: $formattedDate'),
                    ],
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 227, 255, 227),
                    child: Icon(
                      Icons.person,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to handle the month and year selection change
  void _onMonthYearChanged(int? month, int? year) {
    setState(() {
      _selectedMonth = month ?? _selectedMonth;
      _selectedYear = year ?? _selectedYear;
      _isLoading = true; // Start loading
    });
    _initializeDashboard(month: _selectedMonth, year: _selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    _textScaleFactor = MediaQuery.textScalerOf(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 255, 242),
      appBar: AppBar(
        title:  Text('My Deliveries', style: TextStyle(
          fontSize: _textScaleFactor!.scale(20),
        ),),
      ),
      body: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.eco_rounded,
              size: 300,
              color: Color(0xFF13AA52),
            ),
          ),
          _isLoading
              ? Stack(
                  children: [
                    // Blurred Background Effect
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black
                            .withOpacity(0.2), // Semi-transparent layer
                      ),
                    ),
                    // Loading Indicator
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Dropdown menus for month and year selection
                      Row(
                        children: [
                          DropdownButton<int>(
                            value: _selectedMonth,
                            items: List.generate(12, (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text(DateFormat('MMMM').format(DateTime(0, index + 1))),
                              );
                            }),
                            onChanged: (month) => _onMonthYearChanged(month, null),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<int>(
                            value: _selectedYear,
                            items: List.generate(10, (index) {
                              return DropdownMenuItem<int>(
                                value: DateTime.now().year - index,
                                child: Text((DateTime.now().year - index).toString()),
                              );
                            }),
                            onChanged: (year) => _onMonthYearChanged(null, year),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildSupplierList(),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
