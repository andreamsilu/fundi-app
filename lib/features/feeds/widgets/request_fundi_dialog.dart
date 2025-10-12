import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/feeds/services/feeds_service.dart';
import '../models/fundi_model.dart';
import '../models/comprehensive_fundi_profile.dart';

class RequestFundiDialog extends StatefulWidget {
  final dynamic fundi; // Can be FundiModel or ComprehensiveFundiProfile
  final VoidCallback? onRequestSent;

  const RequestFundiDialog({Key? key, required this.fundi, this.onRequestSent})
    : super(key: key);

  @override
  State<RequestFundiDialog> createState() => _RequestFundiDialogState();
}

class _RequestFundiDialogState extends State<RequestFundiDialog> {
  final FeedsService _feedsService = FeedsService();
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deadlineController = TextEditingController();

  String _selectedCategory = '';
  String _budgetType = 'fixed';
  bool _isSubmitting = false;
  bool _isLoadingCategories = true;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  /// Load categories from API
  Future<void> _loadCategories() async {
    try {
      final result = await _feedsService.getJobCategories();
      if (mounted) {
        setState(() {
          if (result['success'] == true && result['categories'] != null) {
            _categories = result['categories'];
            _isLoadingCategories = false;
          } else {
            _categories = [];
            _isLoadingCategories = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categories = [];
          _isLoadingCategories = false;
        });
      }
    }
  }

  /// Get fundi name from either FundiModel or ComprehensiveFundiProfile
  String _getFundiName() {
    if (widget.fundi is FundiModel) {
      return (widget.fundi as FundiModel).name;
    } else if (widget.fundi is ComprehensiveFundiProfile) {
      return (widget.fundi as ComprehensiveFundiProfile).fullName;
    }
    return 'Unknown';
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _deadlineController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get fundi ID - handle both FundiModel and ComprehensiveFundiProfile
    final fundiId = widget.fundi is FundiModel
        ? (widget.fundi as FundiModel).id
        : widget.fundi is ComprehensiveFundiProfile
        ? (widget.fundi as ComprehensiveFundiProfile).id
        : '';

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _feedsService.createJob(
        title: _jobTitleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory,
        budget: double.parse(_budgetController.text),
        budgetType: _budgetType,
        deadline: _deadlineController.text,
        fundiId: fundiId, // Specific fundi request
      );

      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onRequestSent?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          minHeight: screenHeight * 0.6, // Minimum 60% of screen height
          maxHeight: screenHeight * 0.9, // 90% of screen height
          minWidth: screenWidth > 500 ? 500 : screenWidth * 0.9,
          maxWidth: screenWidth > 900
              ? 900
              : screenWidth * 0.98, // Responsive width
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        child: Text(
                          _getFundiName().isNotEmpty
                              ? _getFundiName().substring(0, 1).toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Request Fundi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getFundiName().isNotEmpty
                                  ? _getFundiName()
                                  : 'Unknown Fundi',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Job Title
                  TextFormField(
                    controller: _jobTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Job Title *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a job title';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory.isEmpty ? null : _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      border: const OutlineInputBorder(),
                      suffixIcon: _isLoadingCategories
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
                    items: _categories.map((category) {
                      // Handle both Map and object responses from API
                      final id = category is Map
                          ? (category['id']?.toString() ?? '')
                          : category.toString();
                      final name = category is Map
                          ? (category['name']?.toString() ?? id)
                          : category.toString();

                      return DropdownMenuItem(value: id, child: Text(name));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Job Description *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a job description';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Budget Type and Amount
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _budgetType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Budget Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'fixed',
                              child: Text('Fixed'),
                            ),
                            DropdownMenuItem(
                              value: 'hourly',
                              child: Text('Hourly'),
                            ),
                            DropdownMenuItem(
                              value: 'negotiable',
                              child: Text('Negotiable'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _budgetType = value ?? 'fixed';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _budgetController,
                          decoration: const InputDecoration(
                            labelText: 'Budget (TZS) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter budget';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Deadline
                  TextFormField(
                    controller: _deadlineController,
                    decoration: const InputDecoration(
                      labelText: 'Deadline *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _selectDeadline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select a deadline';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Send Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
