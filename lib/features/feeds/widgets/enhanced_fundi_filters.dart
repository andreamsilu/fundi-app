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
  String? _selectedCategory;
  List<String> _selectedSkills = [];
  double? _minRating;
  bool? _isAvailable;
  bool? _isVerified;
  
  // Advanced filters
  RangeValues? _hourlyRateRange;
  int? _minExperience;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  final List<String> _availableCategories = [
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
    'General',
  ];

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
    _selectedCategory = widget.currentFilters['category'];
    _selectedSkills = List<String>.from(widget.currentFilters['skills'] ?? []);
    _minRating = widget.currentFilters['min_rating'];
    _isAvailable = widget.currentFilters['is_available'];
    _isVerified = widget.currentFilters['is_verified'];
    
    // Initialize advanced filters
    _hourlyRateRange = widget.currentFilters['hourly_rate_range'];
    _minExperience = widget.currentFilters['min_experience'];
    _sortBy = widget.currentFilters['sort_by'] ?? 'created_at';
    _sortOrder = widget.currentFilters['sort_order'] ?? 'desc';
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
      'category': _selectedCategory,
      'skills': _selectedSkills,
      'min_rating': _minRating,
      'is_available': _isAvailable,
      'is_verified': _isVerified,
      
      // Advanced filters
      'min_hourly_rate': _hourlyRateRange?.start,
      'max_hourly_rate': _hourlyRateRange?.end,
      'min_experience': _minExperience,
      'sort_by': _sortBy,
      'sort_order': _sortOrder,
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLocation = null;
      _selectedCategory = null;
      _selectedSkills.clear();
      _minRating = null;
      _isAvailable = null;
      _isVerified = null;
      _hourlyRateRange = null;
      _minExperience = null;
      _sortBy = 'created_at';
      _sortOrder = 'desc';
    });
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_searchController.text.isNotEmpty) count++;
    if (_selectedLocation != null) count++;
    if (_selectedCategory != null) count++;
    if (_selectedSkills.isNotEmpty) count++;
    if (_minRating != null) count++;
    if (_isAvailable != null) count++;
    if (_isVerified != null) count++;
    if (_hourlyRateRange != null) count++;
    if (_minExperience != null) count++;
    if (_sortBy != 'created_at' || _sortOrder != 'desc') count++;
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

          // Category/Profession Filter
          const Text(
            'Profession/Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              hintText: 'Select profession',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Professions'),
              ),
              ..._availableCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
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

          // Hourly Rate Range Filter
          const Text(
            'Hourly Rate (TZS)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _hourlyRateRange ?? const RangeValues(0, 100000),
            min: 0,
            max: 100000,
            divisions: 20,
            labels: RangeLabels(
              _hourlyRateRange?.start.toStringAsFixed(0) ?? '0',
              _hourlyRateRange?.end.toStringAsFixed(0) ?? '100000',
            ),
            onChanged: (values) {
              setState(() {
                _hourlyRateRange = values;
              });
            },
          ),
          if (_hourlyRateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'TZS ${_hourlyRateRange!.start.toStringAsFixed(0)} - TZS ${_hourlyRateRange!.end.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

          const SizedBox(height: 20),

          // Experience Filter
          const Text(
            'Minimum Experience (Years)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: (_minExperience ?? 0).toDouble(),
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _minExperience != null && _minExperience! > 0
                      ? '${_minExperience}+ years'
                      : 'Any',
                  onChanged: (value) {
                    setState(() {
                      _minExperience = value > 0 ? value.toInt() : null;
                    });
                  },
                ),
              ),
              Text(
                _minExperience != null && _minExperience! > 0
                    ? '${_minExperience}+ yrs'
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

          const SizedBox(height: 20),

          // Sorting Options
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Most Recent'),
                selected: _sortBy == 'created_at',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'created_at';
                    _sortOrder = 'desc';
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Highest Rated'),
                selected: _sortBy == 'rating',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'rating';
                    _sortOrder = 'desc';
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Most Experienced'),
                selected: _sortBy == 'experience',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'experience';
                    _sortOrder = 'desc';
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Lowest Price'),
                selected: _sortBy == 'hourly_rate' && _sortOrder == 'asc',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'hourly_rate';
                    _sortOrder = 'asc';
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Most Reviews'),
                selected: _sortBy == 'reviews',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'reviews';
                    _sortOrder = 'desc';
                  });
                },
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
