import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/fundi_model.dart';
import '../../../shared/widgets/optimized_image.dart';

class FundiCard extends StatelessWidget {
  final dynamic fundi;
  final VoidCallback? onTap;

  const FundiCard({Key? key, required this.fundi, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Support both FundiModel and raw Map payloads
    final bool isModel = fundi is FundiModel;
    final String name = isModel
        ? (fundi as FundiModel).name
        : (fundi['name']?.toString() ?? 'Unknown Fundi');
    final double averageRating = isModel
        ? (fundi as FundiModel).rating
        : (fundi['average_rating']?.toDouble() ??
              fundi['rating']?.toDouble() ??
              0.0);
    final int totalRatings = isModel
        ? 0 // Not available on model by default
        : (fundi['total_ratings'] as int? ?? 0);
    final List<dynamic> portfolioItems = () {
      if (isModel) {
        final Map<String, dynamic> portfolio = (fundi as FundiModel).portfolio;
        final items = portfolio['items'];
        if (items is List) return items;
        return const [];
      }
      // Handle both visible_portfolio and portfolio_items from API response
      return fundi['visible_portfolio'] as List<dynamic>? ??
          fundi['portfolio_items'] as List<dynamic>? ??
          const [];
    }();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fundi Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'F',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($totalRatings)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Portfolio Preview
              if (portfolioItems.isNotEmpty) ...[
                Text(
                  'Recent Work',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: portfolioItems.length > 3
                        ? 3
                        : portfolioItems.length,
                    itemBuilder: (context, index) {
                      final item = portfolioItems[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              item['media'] != null &&
                                  (item['media'] as List).isNotEmpty
                              ? OptimizedListImage(
                                  imageUrl: item['media'][0]['url'],
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.work,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (portfolioItems.length > 3)
                  Text(
                    '+${portfolioItems.length - 3} more works',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No portfolio items yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Skills (if available)
              if (!isModel &&
                  fundi['fundi_profile'] != null &&
                  fundi['fundi_profile']['skills'] != null) ...[
                Builder(
                  builder: (context) {
                    final skillsData = fundi['fundi_profile']['skills'];
                    List<String> skills = [];

                    if (skillsData is String) {
                      try {
                        // Parse JSON string like "[\"Plumbing\",\"Pipe Repair\",\"Installation\"]"
                        final decoded = jsonDecode(skillsData) as List<dynamic>;
                        skills = List<String>.from(decoded);
                      } catch (e) {
                        // If parsing fails, treat as comma-separated string
                        skills = skillsData
                            .split(',')
                            .map((s) => s.trim().replaceAll('"', ''))
                            .toList();
                      }
                    } else if (skillsData is List) {
                      skills = List<String>.from(skillsData);
                    }

                    if (skills.isEmpty) return const SizedBox.shrink();

                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: skills
                          .take(3)
                          .map<Widget>(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                skill.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ] else if (isModel &&
                  (fundi as FundiModel).skills.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (fundi as FundiModel).skills
                      .take(3)
                      .map<Widget>(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            skill.toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Profile & Request',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
