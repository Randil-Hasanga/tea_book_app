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
      final collectorUrl =
          '${_userServices!.base_url}/collector';
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
      )
    );
  }
}
