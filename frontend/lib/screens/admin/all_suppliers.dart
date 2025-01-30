import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/services/user_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class AllSuppliers extends StatefulWidget {
  const AllSuppliers({super.key});

  @override
  State<AllSuppliers> createState() => _AllSuppliersState();
}

class _AllSuppliersState extends State<AllSuppliers> {
  final dio = Dio();
  UserServices? _userServices;
  String? _collectorId;
  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> filteredSuppliers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  TextScaler? _textScaleFactor;
  double? _screenWidth, _screenHeight;

  // Declare controllers as member variables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // FormKey for validation

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    _initializeData();
    _searchController.addListener(_filterSuppliers);
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _collectorId = _userServices!.collector_id;
      });
      print('collector id: $_collectorId');
      final suppliersUrl = '${_userServices!.base_url}/supplier';
      final response = await dio.get(suppliersUrl);
      print('Response data: ${response.data}');

      final data = response.data['data'] as List<dynamic>;
      setState(() {
        suppliers = List<Map<String, dynamic>>.from(data);
        filteredSuppliers = suppliers;
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
      filteredSuppliers = suppliers.where((supplier) {
        final name = supplier['supplier_name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search supplier by name',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildSupplierList() {
    if (filteredSuppliers.isEmpty) {
      return const Center(child: Text('No suppliers found'));
    }

    return ListView.builder(
      itemCount: filteredSuppliers.length,
      itemBuilder: (context, index) {
        final supplier = filteredSuppliers[index];
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(supplier['createdAt']));
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              if (supplier['isActive'] == false) ...{
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red
                            .withOpacity(0.4), // Semi-transparent white
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        title: Text(
                          supplier['supplier_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _textScaleFactor!.scale(18),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Phone: ${supplier['supplier_phone']}'),
                            Text('NIC: ${supplier['supplier_NIC']}'),
                            Text('Date of Join: ${formattedDate}'),
                          ],
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 227, 255, 227),
                          child: Icon(
                            Icons.person,
                            color: Colors.green,
                          ),
                        ),
                        trailing: IconButton(
                              onPressed: () => {handleRestoreIconPress(supplier['_id'])},
                              icon: const Icon(
                                Icons.restore,
                                size: 30,
                              ),
                              color: Colors.black,
                              tooltip: 'Activate Supplier',
                            ),
                      ),
                    ),
                  ),
                ),
              } else ...{
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.1), // Semi-transparent white
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        title: Text(
                          supplier['supplier_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _textScaleFactor!.scale(18),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Phone: ${supplier['supplier_phone']}'),
                            Text('NIC: ${supplier['supplier_NIC']}'),
                            Text('Date of Join: ${formattedDate}'),
                          ],
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 227, 255, 227),
                          child: Icon(
                            Icons.person,
                            color: Colors.green,
                          ),
                        ),
                        trailing: IconButton(
                              onPressed: () => {
                                handleDeleteIconPress(supplier['_id']),
                              },
                              icon: const Icon(
                                Icons.delete,
                                size: 30,
                              ),
                              color: Colors.black,
                              tooltip: 'Activate Supplier',
                            ),
                      ),
                    ),
                  ),
                ),
              },
            ],
          ),
        );
      },
    );
  }

  void handleDeleteIconPress(supplier_id) async {
    try {

      setState(() {
        _isLoading = true;
      });
      final url = '${_userServices!.base_url}/supplier/$supplier_id';
      final response = await dio.patch(url, data: {'isActive': false});

      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');

      _initializeData();
      final callback = ModalRoute.of(context)!.settings.arguments as Function?;
      if (callback != null) {
        callback(); // Refresh the dashboard
      }
      setState(() {
        _isLoading = true;
      });
    } catch (e) {
      print('Error deleting supplier: $e');
    }
  }

  void handleRestoreIconPress(supplier_id) async {
    try {

      setState(() {
        _isLoading = true;
      });
      final url = '${_userServices!.base_url}/supplier/$supplier_id';
      final response = await dio.patch(url, data: {'isActive': true});

      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');

      _initializeData();
      final callback = ModalRoute.of(context)!.settings.arguments as Function?;
      if (callback != null) {
        callback(); // Refresh the dashboard
      }
      setState(() {
        _isLoading = true;
      });
    } catch (e) {
      print('Error deleting supplier: $e');
    }
  }

  Widget _buildLoadingIndicator() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _textScaleFactor = MediaQuery.textScalerOf(context);
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 255, 242),
      appBar: AppBar(
        title: const Text('Suppliers'),
      ),
      body: Stack(
        children: [
          // Large leaf icon background
          const Center(
            child: Icon(
              Icons.eco_rounded,
              size: 300,
              color: Color(0xFF13AA52),
            ),
          ),
          _isLoading
              ? _buildLoadingIndicator()
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildSearchBar(),
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
