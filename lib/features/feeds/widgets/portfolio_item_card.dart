import 'package:flutter/material.dart';

class PortfolioItemCard extends StatelessWidget {
  final dynamic portfolioItem;

  const PortfolioItemCard({Key? key, required this.portfolioItem})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (portfolioItem == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Portfolio item not available'),
        ),
      );
    }

    final media = portfolioItem['media'] as List<dynamic>? ?? [];
    final title = portfolioItem['title']?.toString() ?? 'Untitled Work';
    final description = portfolioItem['description']?.toString() ?? '';
    final skillsUsed = portfolioItem['skills_used']?.toString() ?? '';
    final duration = portfolioItem['duration_hours'];
    final budget = portfolioItem['budget'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Media Preview
            if (media.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: media.length > 3 ? 3 : media.length,
                  itemBuilder: (context, index) {
                    final mediaItem = media[index];
                    if (mediaItem == null || mediaItem['url'] == null) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[200],
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    }

                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          mediaItem['url'].toString(),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Description
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],

            // Skills Used
            if (skillsUsed.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: skillsUsed
                    .split(',')
                    .map((skill) {
                      final trimmedSkill = skill.trim();
                      if (trimmedSkill.isEmpty) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          trimmedSkill,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    })
                    .where((widget) => widget != const SizedBox.shrink())
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Duration and Budget
            Row(
              children: [
                if (duration != null) ...[
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${duration}h',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                ],
                if (budget != null) ...[
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${budget.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
