import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:frontend/services/user_services.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui'; // Import for BackdropFilter

class CollectTea extends StatefulWidget {
  const CollectTea({super.key});

  @override
  State<CollectTea> createState() => _CollectTeaState();
}

class _CollectTeaState extends State<CollectTea> {
  final TextEditingController _totalWeightController = TextEditingController();
  final TextEditingController _bagWeightController = TextEditingController();
  double netWeight = 0;
  String? selectedSupplierId;
  String? selectedSupplierName;
  List<Map<String, dynamic>> suppliers = [];
  bool _isLoading = true;

  final dio = Dio();
  UserServices? _userServices;
  String? collectorId;
  bool _isSubmitting = false; // Flag to control the loading screen during submission

  @override
  void initState() {
    super.initState();
    _userServices = GetIt.instance.get<UserServices>();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    try {
      setState(() {
        collectorId = _userServices!.collector_id;
      });
      final suppliersUrl =
          '${_userServices!.base_url}/supplier/createdBy/$collectorId';
      final response = await dio.get(suppliersUrl);
      final data = response.data['data']['suppliers'] as List<dynamic>;
      setState(() {
        suppliers = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void calculateNetWeight() {
    double totalWeight = double.tryParse(_totalWeightController.text) ?? 0;
    double bagWeight = (double.tryParse(_bagWeightController.text) ?? 0) / 1000;
    setState(() {
      netWeight = totalWeight - bagWeight;
    });
  }

  void clearForm() {
    setState(() {
      selectedSupplierId = null;
      selectedSupplierName = null;
      _totalWeightController.clear();
      _bagWeightController.clear();
      netWeight = 0;
    });
  }

  void submitForm() async {
    setState(() {
      _isSubmitting = true; // Show loading indicator
    });

    final requestBody = {
      "supplied_by": selectedSupplierId,
      "collected_by": collectorId,
      "total_weight": double.tryParse(_totalWeightController.text) ?? 0,
      "bag_weight": (double.tryParse(_bagWeightController.text) ?? 0) / 1000,
      "net_weight": netWeight,
    };

    print('Request body: $requestBody');
    try {
      final response = await dio.post('${_userServices!.base_url}/delivery', data: requestBody);

      // Debugging the response
      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tea collected successfully"),
            backgroundColor: Color(0xFF13AA52),
          ),
        );
        clearForm(); // Ensure this gets called when submission is successful
        final callback = ModalRoute.of(context)!.settings.arguments as Function?;
        if (callback != null) {
          callback(); // Refresh the dashboard
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to collect tea"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again later."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background
      appBar: AppBar(
        title: const Text(
          "Collect Tea",
          style: TextStyle(color: Color(0xFF13AA52)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: 100,
                          child: const Icon(
                            Icons.eco,
                            size: 100,
                            color: Color(0xFF13AA52),
                          ),
                        ),
                      ),
                      _buildSupplierAutocomplete(),
                      const SizedBox(height: 16),
                      _buildTextField(_totalWeightController, "Total Weight (kg)"),
                      const SizedBox(height: 16),
                      _buildTextField(_bagWeightController, "Bag Weight (grams)"),
                      const SizedBox(height: 16),
                      _buildNetWeightDisplay(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
                // Blurred background and loading screen overlay
                if (_isSubmitting)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSupplierAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return suppliers
              .map<String>((supplier) => supplier["supplier_name"] as String)
              .toList();
        }
        return suppliers
            .where((supplier) => (supplier['supplier_name'] as String)
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()))
            .map<String>((supplier) => supplier["supplier_name"] as String)
            .toList();
      },
      onSelected: (String selection) {
        final selectedSupplier = suppliers.firstWhere(
            (supplier) => supplier["supplier_name"] == selection,
            orElse: () => {});
        setState(() {
          selectedSupplierName = selection;
          selectedSupplierId = selectedSupplier["_id"];
        });
      },
      fieldViewBuilder:
          (context, controller, focusNode, onEditingComplete) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: "Select Supplier",
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF13AA52)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF13AA52)),
        ),
      ),
      onChanged: (value) => calculateNetWeight(),
    );
  }

  Widget _buildNetWeightDisplay() {
    return Center(
      child: Text(
        "Net Weight: $netWeight kg",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF13AA52),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF13AA52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: clearForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text("Clear", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
