import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/services/user_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class AllCollectors extends StatefulWidget {
  const AllCollectors({super.key});

  @override
  State<AllCollectors> createState() => _AllCollectorsState();
}

class _AllCollectorsState extends State<AllCollectors> {
  final dio = Dio();
  UserServices? _userServices;
  String? _collectorId;
  List<Map<String, dynamic>> collectors = [];
  List<Map<String, dynamic>> filteredCollectors = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    _initializeData();
    _searchController.addListener(_filterCollectors);
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _collectorId = _userServices!.collector_id;
      });
      print('collector id: $_collectorId');
      final collectorUrl = '${_userServices!.base_url}/collector';
      final response = await dio.get(collectorUrl);
      print('Response data: ${response.data}');

      final data = response.data['data'] as List<dynamic>;
      setState(() {
        collectors = List<Map<String, dynamic>>.from(data);
        filteredCollectors = collectors;
      });
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCollectors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCollectors = collectors.where((collector) {
        final name = collector['collector_name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search collector by name',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildCollectorsList() {
    if (filteredCollectors.isEmpty) {
      return const Center(child: Text('No collectors found'));
    }

    return ListView.builder(
      itemCount: filteredCollectors.length,
      itemBuilder: (context, index) {
        final collector = filteredCollectors[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              if (collector['_id'] != _collectorId) ...{
                if (collector['isActive'] == false) ...{
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
                            collector['collector_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Email: ${collector['collector_email']}'),
                              Text('Phone: ${collector['collector_phone']}'),
                              Text('NIC: ${collector['collector_NIC']}'),
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
                              handleRestoreIconPress(collector['_id']),
                            },
                            icon: const Icon(
                              Icons.restore,
                              size: 30,
                            ),
                            color: Colors.black,
                            tooltip: 'Activate Collector',
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
                            collector['collector_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Username: ${collector['collector_email']}'),
                              Text('Phone: ${collector['collector_phone']}'),
                              Text('NIC: ${collector['collector_NIC']}'),
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
                              handleDeleteIconPress(collector['_id']),
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 30,
                            ),
                            color: Colors.black,
                            tooltip: 'Disable Collector',
                          ),
                        ),
                      ),
                    ),
                  ),
                },
              }
            ],
          ),
        );
      },
    );
  }

  void handleDeleteIconPress(collector_id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final url = '${_userServices!.base_url}/collector/$collector_id';
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

  void handleRestoreIconPress(collector_id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final url = '${_userServices!.base_url}/collector/$collector_id';
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 255, 242),
      appBar: AppBar(
        title: const Text('Collectors'),
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
                        child: _buildCollectorsList(),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddCollecor,
        backgroundColor: const Color(0xFF13AA52),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _onAddCollecor() {
    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Collector'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey, // Add the form key here
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Collector Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter collector name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Collector Username',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter collector username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Collector Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter collector password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Collector Phone',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter collector phone number';
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
                      labelText: 'Collector NIC',
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
                  String collectorName = _nameController.text;
                  String collectorEmail = _emailController.text;
                  String collectorPassword = _passwordController.text;
                  String collectorPhone = _phoneController.text;
                  String collectorNIC = _nicController.text;

                  // Print to the console (save supplier logic)
                  print(
                      'collector added: $collectorName, $collectorEmail, $collectorPhone, $collectorNIC');
                  Navigator.of(context).pop();
                  addCollector();

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

  void addCollector() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await dio.post(
        '${_userServices!.base_url}/collector',
        data: {
          'collector_name': _nameController.text,
          'collector_email': _emailController.text,
          'collector_password': _passwordController.text,
          'collector_phone': _phoneController.text,
          'collector_NIC': _nicController.text,
          'created_by': _collectorId,
          'isActive': true,
        },
      );
      print('Response: ${response.data}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Collector Added Successfully'),
          backgroundColor: Color(0xFF13AA52),
        ),
      );

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
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error adding collector'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
}
