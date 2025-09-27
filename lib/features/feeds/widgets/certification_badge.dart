import 'package:flutter/material.dart';

/// Widget to display certification badges
class CertificationBadge extends StatelessWidget {
  final String certification;
  final bool isVerified;
  final IconData? icon;

  const CertificationBadge({
    Key? key,
    required this.certification,
    this.isVerified = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified
            ? Colors.green.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? Colors.green : Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isVerified ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            certification,
            style: TextStyle(
              color: isVerified ? Colors.green : Colors.blue,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 14, color: Colors.green),
          ],
        ],
      ),
    );
  }
}
