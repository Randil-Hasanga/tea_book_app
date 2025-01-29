import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/services/user_services.dart';
import 'package:frontend/widgets/rounded_card.dart';
import 'package:get_it/get_it.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final dio = Dio();
  UserServices? _userServices;

  Response<dynamic>? suppliersResponse, collectorsResponse;
  int supplierCount = 0, collectorCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    _initializeDashboard(); // Start async logic
  }

  Future<void> _initializeDashboard() async {
    try {
      final suppliersURL = '${_userServices!.base_url}/supplier';
      final collectorsURL = '${_userServices!.base_url}/collector';

      final suppliers = await dio.get(suppliersURL);
      final collectors = await dio.get(collectorsURL);

      setState(() {
        // Getting the length of the array in the 'data' field
        supplierCount = suppliers.data['data']?.length ?? 0;
        collectorCount = collectors.data['data']?.length ?? 0;
        isLoading = false; // Loading completed
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
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
                        Icons.dashboard,
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
                                "Suppliers", supplierCount, 235),
                            _buildDashboardCard(
                                "Collectors", collectorCount, 110),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNavigationCard(
                                'Suppliers', Icons.people, '/admin-suppliers'),
                            _buildNavigationCard(
                                'Collectors', Icons.group, '/admin-collectors'),
                            _buildNavigationCard('Edit Price',
                                Icons.attach_money, _showEditPriceDialog),
                          ],
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

  Widget _buildDashboardCard(String title, int count, double width) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 120,
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
                count.toString(),
                style: const TextStyle(
                    fontSize: 50, color: Color.fromARGB(255, 35, 209, 93)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(String title, IconData icon, dynamic onTap) {
    return InkWell(
      onTap: () {
        if (onTap is String) {
          Navigator.pushNamed(context, onTap);
        } else if (onTap is Function) {
          onTap();
        }
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

void _showEditPriceDialog() {
  final currentDate = DateTime.now();
  final currentMonth = currentDate.month;
  final currentYear = currentDate.year;

  TextEditingController priceController = TextEditingController();
  bool isLoading = false; // Track the loading state

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dialog from being closed
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Price'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the current month and year
                Text('Current Month: $currentMonth/$currentYear'),
                const SizedBox(height: 10),
                // Price input field
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Enter New Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                // Loading indicator
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () {
                  if (!isLoading) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Cancel'),
              ),
              // Assign price button
              TextButton(
                onPressed: () async {
                  String enteredPrice = priceController.text;
                  if (enteredPrice.isNotEmpty && !isLoading) {
                    try {
                      setState(() {
                        isLoading = true; // Start loading
                      });
                      // Send POST request to assign price
                      final url =
                          '${_userServices!.base_url}/price?price=$enteredPrice&month=$currentMonth&year=$currentYear';
                      try {
                        final response = await dio.post(url);
                        print(response.data);

                        if (response.statusCode == 201) {
                          // Success response handling
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Price assigned successfully!'),
                                backgroundColor: Colors.green),
                          );
                          Navigator.of(context).pop(); // Close the dialog
                        } else {
                          // Handle error if not success
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to assign price')),
                          );
                        }
                      } on Exception catch (e) {
                        print("error $e");
                      }
                    } catch (e) {
                      // Handle any error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error assigning price')),
                      );
                      print('Error: $e');
                    } finally {
                      setState(() {
                        isLoading = false; // Stop loading
                      });
                    }
                  } else {
                    // Show an error if price is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a price')),
                    );
                  }
                },
                child: const Text('Assign Price'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Widget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Center(
        child: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
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
