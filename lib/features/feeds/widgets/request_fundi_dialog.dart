import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/feeds/services/feeds_service.dart';

class RequestFundiDialog extends StatefulWidget {
  final dynamic fundi;
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

  final List<Map<String, String>> _categories = [
    {'id': '1', 'name': 'Plumbing'},
    {'id': '2', 'name': 'Electrical'},
    {'id': '3', 'name': 'Carpentry'},
    {'id': '4', 'name': 'Painting'},
    {'id': '5', 'name': 'Masonry'},
    {'id': '6', 'name': 'Roofing'},
  ];

  @override
  void dispose() {
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    super.dispose();
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

    // Validate fundi ID
    final fundiId = widget.fundi?['id']?.toString();
    if (fundiId == null || fundiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid fundi information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

      if (result['success']) {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
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
                          (widget.fundi?['name']?.toString() ??
                                  widget.fundi?['full_name']?.toString() ??
                                  'Unknown')
                              .substring(0, 1)
                              .toUpperCase(),
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
                              widget.fundi?['name']?.toString() ??
                                  widget.fundi?['full_name']?.toString() ??
                                  'Unknown Fundi',
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
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category['id'],
                        child: Text(category['name']!),
                      );
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
