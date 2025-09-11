import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Category card widget for displaying category information
class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon and name
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.name),
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Category name
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Selection indicator
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                ],
              ),
              
              if (category.description != null && category.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  category.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Category stats
              Row(
                children: [
                  Icon(
                    Icons.work,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${category.jobCount} jobs',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'carpentry':
        return Icons.build;
      case 'painting':
        return Icons.format_paint;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'gardening':
        return Icons.grass;
      case 'cooking':
        return Icons.restaurant;
      case 'driving':
        return Icons.drive_eta;
      case 'tutoring':
        return Icons.school;
      case 'beauty':
        return Icons.face;
      case 'fitness':
        return Icons.fitness_center;
      case 'photography':
        return Icons.camera_alt;
      case 'music':
        return Icons.music_note;
      case 'writing':
        return Icons.edit;
      case 'translation':
        return Icons.translate;
      case 'repair':
        return Icons.build_circle;
      case 'installation':
        return Icons.install_mobile;
      case 'maintenance':
        return Icons.handyman;
      case 'delivery':
        return Icons.local_shipping;
      case 'other':
        return Icons.category;
      default:
        return Icons.work;
    }
  }
}

/// Category grid widget
class CategoryGridWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategorySelected;
  final CategoryModel? selectedCategory;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const CategoryGridWidget({
    super.key,
    required this.categories,
    this.onCategorySelected,
    this.selectedCategory,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Categories will appear here when available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            onTap: onCategorySelected != null ? () => onCategorySelected!(category) : null,
            isSelected: selectedCategory?.id == category.id,
          );
        },
      ),
    );
  }
}

/// Category list widget
class CategoryListWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategorySelected;
  final CategoryModel? selectedCategory;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const CategoryListWidget({
    super.key,
    required this.categories,
    this.onCategorySelected,
    this.selectedCategory,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Categories will appear here when available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            onTap: onCategorySelected != null ? () => onCategorySelected!(category) : null,
            isSelected: selectedCategory?.id == category.id,
          );
        },
      ),
    );
  }
}

/// Category search widget
class CategorySearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategorySelected;
  final CategoryModel? selectedCategory;

  const CategorySearchWidget({
    super.key,
    required this.onSearch,
    required this.categories,
    this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<CategorySearchWidget> createState() => _CategorySearchWidgetState();
}

class _CategorySearchWidgetState extends State<CategorySearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearch('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: widget.onSearch,
          ),
          
          const SizedBox(height: 16),
          
          // Categories
          Expanded(
            child: CategoryListWidget(
              categories: widget.categories,
              onCategorySelected: widget.onCategorySelected,
              selectedCategory: widget.selectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}
