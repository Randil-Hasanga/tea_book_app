import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/services/user_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class SupplierSalariesPage extends StatefulWidget {
  const SupplierSalariesPage({super.key});

  @override
  State<SupplierSalariesPage> createState() => _SupplierSalariesPageState();
}

class _SupplierSalariesPageState extends State<SupplierSalariesPage> {
  final dio = Dio();
  UserServices? _userServices;
  String? _supplierId;
  List<Map<String, dynamic>> salaries = [];
  List<Map<String, dynamic>> filteredSalaries = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  double? _screenWidth, _screenHeight;
  TextScaler? _textScaleFactor;

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    _initializeDashboard();
    _searchController.addListener(_filterSuppliers);
  }

  // Method to initialize the dashboard with data
  Future<void> _initializeDashboard() async {
    try {
      setState(() {
        _supplierId = _userServices!.supplier_id;
      });
      print('supplier id: $_supplierId');

      final salariesURL = '${_userServices!.base_url}/salary/all/$_supplierId';
      print('Requesting URL: $salariesURL');

      final response = await dio.get(salariesURL);

      final data = response.data;

      if (response.statusCode == 404) {
        print("No salaries found for this supplier");
        setState(() {
          salaries = [];
          filteredSalaries = [];
        });
      } else if (data is List) {
        // Assuming the response data is a list of salary records
        final List<Map<String, dynamic>> salaryList =
            List<Map<String, dynamic>>.from(data);

        // Sort salaries from latest to oldest based on createdAt
        salaryList.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        setState(() {
          salaries = salaryList;
          filteredSalaries = salaries;
        });
      } else {
        print("Invalid data format");
        setState(() {
          salaries = [];
          filteredSalaries = [];
        });
      }
    } on DioException catch (e) {
      print('Error fetching data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print("No salaries found for this supplier (404)");
        setState(() {
          salaries = [];
          filteredSalaries = [];
        });
      } else {
        print("Unexpected error: ${e.response?.statusCode}");
        setState(() {
          salaries = [];
          filteredSalaries = [];
        });
      }
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        salaries = [];
        filteredSalaries = [];
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
      filteredSalaries = salaries.where((salary) {
        final salaryId = salary['_id'].toLowerCase();
        return salaryId.contains(query);
      }).toList();
    });
  }

  Widget _buildSupplierList() {
    if (filteredSalaries.isEmpty) {
      return const Center(child: Text('No salaries found for this supplier'));
    }

    return ListView.builder(
      itemCount: filteredSalaries.length,
      itemBuilder: (context, index) {
        final salary = filteredSalaries[index];
        final date = DateTime.parse(salary['createdAt']);
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
        final month = DateFormat('MMMM').format(date); // Month as String
        final year = DateFormat('yyyy').format(date); // Year

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
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '$month ', // Month in regular text
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _textScaleFactor!.scale(16),
                          ),
                          children: [
                            TextSpan(
                              text: year, // Year in normal style
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs.${salary['salary'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _textScaleFactor!.scale(18),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Tea Delivered: ${salary['tea_delivered']} kg'),
                    ],
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 227, 255, 227),
                    child: Icon(
                      Icons.attach_money,
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
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _textScaleFactor = MediaQuery.textScalerOf(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 255, 242),
      appBar: AppBar(
        title: const Text('Supplier Salaries'),
      ),
      body: Stack(
        children: [
          Center(
            child: Icon(
              Icons.eco_rounded,
              size: _screenWidth! * 0.5,
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
                  padding: EdgeInsets.symmetric(
                      horizontal: _screenWidth! * 0.05,
                      vertical: _screenHeight! * 0.01),
                  child: _buildSupplierList(),
                ),
        ],
      ),
    );
  }
}
