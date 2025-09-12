import 'package:flutter/material.dart';

class JobFeedFilters extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const JobFeedFilters({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<JobFeedFilters> createState() => _JobFeedFiltersState();
}

class _JobFeedFiltersState extends State<JobFeedFilters> {
  late TextEditingController _searchController;
  String? _selectedCategory;
  double? _minBudget;
  double? _maxBudget;
  String? _selectedLocation;
  
  final List<Map<String, String>> _categories = [
    {'id': '1', 'name': 'Plumbing'},
    {'id': '2', 'name': 'Electrical'},
    {'id': '3', 'name': 'Carpentry'},
    {'id': '4', 'name': 'Painting'},
    {'id': '5', 'name': 'Masonry'},
    {'id': '6', 'name': 'Roofing'},
    {'id': '7', 'name': 'Flooring'},
    {'id': '8', 'name': 'Tiling'},
    {'id': '9', 'name': 'Welding'},
    {'id': '10', 'name': 'Mechanical'},
    {'id': '11', 'name': 'HVAC'},
    {'id': '12', 'name': 'Landscaping'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.currentFilters['search'] ?? '',
    );
    _selectedCategory = widget.currentFilters['category'];
    _minBudget = widget.currentFilters['min_budget'];
    _maxBudget = widget.currentFilters['max_budget'];
    _selectedLocation = widget.currentFilters['location'];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'search': _searchController.text.trim(),
      'category': _selectedCategory,
      'min_budget': _minBudget,
      'max_budget': _maxBudget,
      'location': _selectedLocation,
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _minBudget = null;
      _maxBudget = null;
      _selectedLocation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Filter Jobs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Search
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search jobs',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Category Filter
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select category',
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category['id'],
                child: Text(category['name']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Budget Range
          const Text(
            'Budget Range (TZS)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min Budget',
                    border: OutlineInputBorder(),
                    prefixText: 'TZS ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minBudget = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max Budget',
                    border: OutlineInputBorder(),
                    prefixText: 'TZS ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxBudget = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Location Filter
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select location',
            ),
            items: const [
              DropdownMenuItem(value: 'Dar es Salaam', child: Text('Dar es Salaam')),
              DropdownMenuItem(value: 'Arusha', child: Text('Arusha')),
              DropdownMenuItem(value: 'Mwanza', child: Text('Mwanza')),
              DropdownMenuItem(value: 'Dodoma', child: Text('Dodoma')),
              DropdownMenuItem(value: 'Tanga', child: Text('Tanga')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLocation = value;
              });
            },
          ),
          
          const SizedBox(height: 30),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
