import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/services/user_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final dio = Dio();
  UserServices? _userServices;
  String? _collectorId;
  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> filteredSuppliers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

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
      final suppliersUrl =
          '${_userServices!.base_url}/supplier/createdBy/$_collectorId';
      final response = await dio.get(suppliersUrl);
      final data = response.data['data']['suppliers'] as List<dynamic>;
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
                  color:
                      Colors.white.withOpacity(0.1), // Semi-transparent white
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
                      Text('Email: ${supplier['supplier_email']}'),
                      Text('Phone: ${supplier['supplier_phone']}'),
                      Text('NIC: ${supplier['supplier_NIC']}'),
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

  void _onAddSupplier() {
    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Supplier'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey, // Add the form key here
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Phone',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier phone number';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _nicController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier NIC',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier NIC';
                      }
                      // NIC validation: 9 digits + V or 12 digits
                      if (!RegExp(r'^\d{9}[Vv]$').hasMatch(value) &&
                          !RegExp(r'^\d{12}$').hasMatch(value)) {
                        return 'Invalid NIC format';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate the form
                if (_formKey.currentState?.validate() ?? false) {
                  // Logic to save the supplier
                  String supplierName = _nameController.text;
                  String supplierEmail = _emailController.text;
                  String supplierPassword = _passwordController.text;
                  String supplierPhone = _phoneController.text;
                  String supplierNIC = _nicController.text;

                  // Print to the console (save supplier logic)
                  print(
                      'Supplier added: $supplierName, $supplierEmail, $supplierPhone, $supplierNIC');
                  Navigator.of(context).pop();
                  addSupplier();

                  // Close the dialog after saving
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Clear all the text fields
                _nameController.clear();
                _emailController.clear();
                _passwordController.clear();
                _phoneController.clear();
                _nicController.clear();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void addSupplier() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await dio.post(
        '${_userServices!.base_url}/supplier',
        data: {
          'supplier_name': _nameController.text,
          'supplier_email': _emailController.text,
          'supplier_password': _passwordController.text,
          'supplier_phone': _phoneController.text,
          'supplier_NIC': _nicController.text,
          'created_by': _collectorId,
          'isActive': true,
        },
      );
      print('Response: ${response.data}');

      await _initializeData();

      final callback = ModalRoute.of(context)!.settings.arguments as Function?;
      if (callback != null) {
        callback(); // Refresh the dashboard
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error adding supplier: $e');
    } finally {}
  }

  @override
  void dispose() {
    // Dispose the controllers when the page is disposed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddSupplier,
        backgroundColor: const Color(0xFF13AA52),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
