import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MandiPriceApp());
}

class MandiPriceApp extends StatelessWidget {
  const MandiPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mandi Prices',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Dynamic light/dark theme
      home: const MandiPricePage(),
    );
  }
}

class MandiPricePage extends StatefulWidget {
  const MandiPricePage({super.key});

  @override
  State<MandiPricePage> createState() => _MandiPricePageState();
}

class _MandiPricePageState extends State<MandiPricePage> {
  List<dynamic> _mandiData = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedData(); // Load cached data on start
    _fetchMandiPrices(); // Fetch fresh data
    _searchController.addListener(_filterData); // Search listener
  }

  // Fetch data from API
  Future<void> _fetchMandiPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const String apiUrl =
        'https://www.data.gov.in/resource/current-daily-price-various-commodities-various-markets-mandi';
    const String apiKey = '579b464db66ec23bdd0000019951b5966e614fa57cd9c8cecc87cc9c';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _mandiData = data; // Adjust based on actual API response structure
          _filteredData = _mandiData;
          _isLoading = false;
        });
        _cacheData(data); // Cache the fetched data
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      _loadCachedData(); // Fallback to cached data
    }
  }

  // Cache data using SharedPreferences
  Future<void> _cacheData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mandi_data', jsonEncode(data));
  }

  // Load cached data
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('mandi_data');
    if (cachedData != null) {
      setState(() {
        _mandiData = jsonDecode(cachedData);
        _filteredData = _mandiData;
      });
    }
  }

  // Filter data based on search input
  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _mandiData.where((item) {
        return item['State'].toString().toLowerCase().contains(query) ||
            item['Market'].toString().toLowerCase().contains(query) ||
            item['Commodity'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  // Placeholder for export functionality (CSV/PDF)
  void _exportData() {
    // Add logic for CSV/PDF export using packages like `csv` or `pdf`
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data as CSV/PDF...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Prices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMandiPrices, // Manual refresh
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData, // Export button
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by State, Market, or Commodity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('State')),
                            DataColumn(label: Text('Market')),
                            DataColumn(label: Text('Commodity')),
                            DataColumn(label: Text('Min Price')),
                            DataColumn(label: Text('Max Price')),
                            DataColumn(label: Text('Modal Price')),
                          ],
                          rows: _filteredData.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item['State'] ?? '')),
                              DataCell(Text(item['Market'] ?? '')),
                              DataCell(Text(item['Commodity'] ?? '')),
                              DataCell(Text(item['Min Price']?.toString() ?? '')),
                              DataCell(Text(item['Max Price']?.toString() ?? '')),
                              DataCell(Text(item['Modal Price']?.toString() ?? '')),
                            ]);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}