import 'package:flutter/material.dart';

class FundiFeedFilters extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FundiFeedFilters({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FundiFeedFilters> createState() => _FundiFeedFiltersState();
}

class _FundiFeedFiltersState extends State<FundiFeedFilters> {
  late TextEditingController _searchController;
  String? _selectedLocation;
  List<String> _selectedSkills = [];
  double? _minRating;
  
  final List<String> _availableSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Masonry',
    'Roofing',
    'Flooring',
    'Tiling',
    'Welding',
    'Mechanical',
    'HVAC',
    'Landscaping',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.currentFilters['search'] ?? '',
    );
    _selectedLocation = widget.currentFilters['location'];
    _selectedSkills = List<String>.from(widget.currentFilters['skills'] ?? []);
    _minRating = widget.currentFilters['min_rating'];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'search': _searchController.text.trim(),
      'location': _selectedLocation,
      'skills': _selectedSkills,
      'min_rating': _minRating,
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLocation = null;
      _selectedSkills.clear();
      _minRating = null;
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
                'Filter Fundis',
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
              labelText: 'Search by name or skills',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
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
          
          const SizedBox(height: 20),
          
          // Skills Filter
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Rating Filter
          const Text(
            'Minimum Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _minRating ?? 0.0,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  label: _minRating != null ? '${_minRating!.toStringAsFixed(1)}+' : 'Any',
                  onChanged: (value) {
                    setState(() {
                      _minRating = value > 0 ? value : null;
                    });
                  },
                ),
              ),
              Text(
                _minRating != null ? '${_minRating!.toStringAsFixed(1)}+' : 'Any',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
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
