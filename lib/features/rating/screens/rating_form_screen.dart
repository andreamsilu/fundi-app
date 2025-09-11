import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rating_provider.dart';
import '../models/rating_model.dart';
import '../widgets/star_rating_widget.dart';

/// Rating form screen for creating/editing ratings
class RatingFormScreen extends StatefulWidget {
  final String fundiId;
  final String fundiName;
  final String? fundiImageUrl;
  final String jobId;
  final String jobTitle;
  final RatingModel? existingRating;

  const RatingFormScreen({
    super.key,
    required this.fundiId,
    required this.fundiName,
    this.fundiImageUrl,
    required this.jobId,
    required this.jobTitle,
    this.existingRating,
  });

  @override
  State<RatingFormScreen> createState() => _RatingFormScreenState();
}

class _RatingFormScreenState extends State<RatingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    
    // Pre-fill with existing rating if editing
    if (widget.existingRating != null) {
      _selectedRating = widget.existingRating!.rating;
      _reviewController.text = widget.existingRating!.review ?? '';
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRating != null ? 'Edit Rating' : 'Rate Fundi'),
        elevation: 0,
      ),
      body: Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fundi info card
                  _buildFundiInfoCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Rating section
                  _buildRatingSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Review section
                  _buildReviewSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ratingProvider.isLoading ? null : _submitRating,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: ratingProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.existingRating != null ? 'Update Rating' : 'Submit Rating',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rating guidelines
                  _buildRatingGuidelines(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFundiInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Fundi image
          CircleAvatar(
            radius: 30,
            backgroundImage: widget.fundiImageUrl != null
                ? NetworkImage(widget.fundiImageUrl!)
                : null,
            child: widget.fundiImageUrl == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          
          const SizedBox(width: 16),
          
          // Fundi info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fundiName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Job: ${widget.jobTitle}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you rate this fundi?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Center(
          child: StarRatingWidget(
            rating: _selectedRating,
            onRatingChanged: (rating) {
              setState(() {
                _selectedRating = rating;
              });
            },
            size: 40,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Center(
          child: Text(
            _getRatingDescription(_selectedRating),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _selectedRating > 0 ? Colors.orange[600] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Write a review (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _reviewController,
          decoration: const InputDecoration(
            hintText: 'Share your experience with this fundi...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16),
          ),
          maxLines: 5,
          maxLength: 1000,
          validator: (value) {
            if (value != null && value.length > 1000) {
              return 'Review must be 1000 characters or less';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRatingGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Rating Guidelines',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• 5 stars: Excellent work, exceeded expectations\n'
            '• 4 stars: Very good work, met all expectations\n'
            '• 3 stars: Good work, met most expectations\n'
            '• 2 stars: Fair work, some issues\n'
            '• 1 star: Poor work, many issues',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final ratingProvider = context.read<RatingProvider>();
    bool success;

    if (widget.existingRating != null) {
      // Update existing rating
      success = await ratingProvider.updateRating(
        ratingId: widget.existingRating!.id,
        rating: _selectedRating,
        review: _reviewController.text.trim().isNotEmpty
            ? _reviewController.text.trim()
            : null,
      );
    } else {
      // Create new rating
      success = await ratingProvider.createRating(
        fundiId: widget.fundiId,
        jobId: widget.jobId,
        rating: _selectedRating,
        review: _reviewController.text.trim().isNotEmpty
            ? _reviewController.text.trim()
            : null,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop(true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingRating != null 
                ? 'Rating updated successfully' 
                : 'Rating submitted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ratingProvider.errorMessage ?? 'Failed to submit rating'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }
}
