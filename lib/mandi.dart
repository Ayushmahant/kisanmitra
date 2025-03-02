import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MandiPriceApp extends StatelessWidget {
  const MandiPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mandi Prices',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
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
    _loadCachedData();
    _fetchMandiPrices();
    _searchController.addListener(_filterData);
  }

  // Fetch Data from API
  Future<void> _fetchMandiPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const String apiUrl =
        'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=579b464db66ec23bdd0000014f344e23bf3e490a4bdc8511437c97da&format=json&limit=10';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}'); // DEBUG API RESPONSE

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['records'] == null || data['records'].isEmpty) {
          throw Exception('No data found in API response');
        }

        setState(() {
          _mandiData = List.from(data['records']);
          _filteredData = List.from(_mandiData);
          _isLoading = false;
        });

        _cacheData(_mandiData);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      _loadCachedData();
    }
  }

  // Cache Data
  Future<void> _cacheData(List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mandi_data', jsonEncode(data));
  }

  // Load Cached Data
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('mandi_data');
    if (cachedData != null) {
      setState(() {
        _mandiData = jsonDecode(cachedData);
        _filteredData = List.from(_mandiData);
      });
    }
  }

  // Search Filtering
  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _mandiData.where((item) {
        return (item['state']?.toString().toLowerCase() ?? '').contains(query) ||
            (item['market']?.toString().toLowerCase() ?? '').contains(query) ||
            (item['commodity']?.toString().toLowerCase() ?? '').contains(query);
      }).toList();
    });
  }

  // Export Data Placeholder
  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data as CSV/PDF...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Prices'),
        leading: IconButton( // 🔙 ADD BACK BUTTON
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMandiPrices,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
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
                : _filteredData.isEmpty
                ? const Center(child: Text('No data available'))
                : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
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
                      DataCell(Text(item['state'] ?? 'N/A')),
                      DataCell(Text(item['market'] ?? 'N/A')),
                      DataCell(Text(item['commodity'] ?? 'N/A')),
                      DataCell(Text(item['min_price']?.toString() ?? 'N/A')),
                      DataCell(Text(item['max_price']?.toString() ?? 'N/A')),
                      DataCell(Text(item['modal_price']?.toString() ?? 'N/A')),
                    ]);
                  }).toList(),
                ),
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
