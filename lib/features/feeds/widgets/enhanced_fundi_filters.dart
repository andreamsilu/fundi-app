import 'package:flutter/material.dart';
import 'autocomplete_search_field.dart';

class EnhancedFundiFilters extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;
  final List<String>? recentSearches;

  const EnhancedFundiFilters({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
    this.recentSearches,
  }) : super(key: key);

  @override
  State<EnhancedFundiFilters> createState() => _EnhancedFundiFiltersState();
}

class _EnhancedFundiFiltersState extends State<EnhancedFundiFilters> {
  late TextEditingController _searchController;
  String? _selectedLocation;
  List<String> _selectedSkills = [];
  double? _minRating;
  bool? _isAvailable;
  bool? _isVerified;

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
    'Gardening',
    'Cleaning',
    'Security',
    'Cooking',
    'Driving',
    'Tailoring',
    'Hair Styling',
    'Beauty Services',
  ];

  final List<String> _availableLocations = [
    'Dar es Salaam',
    'Arusha',
    'Mwanza',
    'Dodoma',
    'Tanga',
    'Morogoro',
    'Mbeya',
    'Iringa',
    'Tabora',
    'Kigoma',
    'Mtwara',
    'Lindi',
    'Ruvuma',
    'Kilimanjaro',
    'Manyara',
    'Singida',
    'Shinyanga',
    'Kagera',
    'Mara',
    'Geita',
    'Simiyu',
    'Njombe',
    'Katavi',
    'Songwe',
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
    _isAvailable = widget.currentFilters['is_available'];
    _isVerified = widget.currentFilters['is_verified'];
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
      'is_available': _isAvailable,
      'is_verified': _isVerified,
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLocation = null;
      _selectedSkills.clear();
      _minRating = null;
      _isAvailable = null;
      _isVerified = null;
    });
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_searchController.text.isNotEmpty) count++;
    if (_selectedLocation != null) count++;
    if (_selectedSkills.isNotEmpty) count++;
    if (_minRating != null) count++;
    if (_isAvailable != null) count++;
    if (_isVerified != null) count++;
    return count;
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_activeFiltersCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_activeFiltersCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search with Autocomplete
          AutocompleteSearchField(
            hintText: 'Search by name, skills, or location',
            initialValue: _searchController.text,
            onChanged: (value) {
              _searchController.text = value;
            },
            recentSearches: widget.recentSearches,
            onSuggestionSelected: (suggestion) {
              _searchController.text = suggestion;
            },
          ),

          const SizedBox(height: 20),

          // Location Filter with Autocomplete
          const Text(
            'Location',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return _availableLocations;
              }
              return _availableLocations.where(
                (location) => location.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            onSelected: (String selection) {
              setState(() {
                _selectedLocation = selection;
              });
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  controller.text = _selectedLocation ?? '';
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Select or type location',
                      border: const OutlineInputBorder(),
                      suffixIcon: _selectedLocation != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedLocation = null;
                                  controller.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          _selectedLocation = null;
                        });
                      }
                    },
                  );
                },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Skills Filter
          const Text(
            'Skills',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  label: _minRating != null
                      ? '${_minRating!.toStringAsFixed(1)}+'
                      : 'Any',
                  onChanged: (value) {
                    setState(() {
                      _minRating = value > 0 ? value : null;
                    });
                  },
                ),
              ),
              Text(
                _minRating != null
                    ? '${_minRating!.toStringAsFixed(1)}+'
                    : 'Any',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status Filters
          const Text(
            'Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Available'),
                  selected: _isAvailable == true,
                  onSelected: (selected) {
                    setState(() {
                      _isAvailable = selected ? true : null;
                    });
                  },
                  selectedColor: Colors.green.withOpacity(0.2),
                  checkmarkColor: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: const Text('Verified'),
                  selected: _isVerified == true,
                  onSelected: (selected) {
                    setState(() {
                      _isVerified = selected ? true : null;
                    });
                  },
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                ),
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
              child: Text(
                _activeFiltersCount > 0
                    ? 'Apply Filters ($_activeFiltersCount)'
                    : 'Apply Filters',
                style: const TextStyle(
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
