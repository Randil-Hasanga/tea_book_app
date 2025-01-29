import 'dart:ui';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    _initializeDashboard();
    _searchController.addListener(_filterSuppliers);
  }

  Future<void> _initializeDashboard() async {
    try {
      setState(() {
        _collectorId = _userServices!.collector_id;
      });
      print('collector id: $_collectorId');

      final now = DateTime.now();
      final int currentMonth = now.month;
      final int currentYear = now.year;

      final deliveriesURL =
          '${_userServices!.base_url}/delivery?collectorId=$_collectorId&month=$currentMonth&year=$currentYear';
      final response = await dio.get(deliveriesURL);

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response.data);

      // Sort deliveries from latest to oldest based on createdAt
      data.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));

      setState(() {
        deliveries = data;
        filteredDeliveries = deliveries;
      });
    } catch (e) {
      print('Error fetching data: $e');
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
      return const Center(child: Text('No suppliers found'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 255, 242),
      appBar: AppBar(
        title: const Text('My Deliveries'),
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
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search supplier by name',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
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
