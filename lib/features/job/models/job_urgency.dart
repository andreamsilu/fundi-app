import 'package:flutter/material.dart';

/// Job urgency levels for prioritizing job postings
enum JobUrgency {
  low('Low', Icons.schedule, 'Low priority'),
  normal('Normal', Icons.work, 'Normal priority'),
  high('High', Icons.priority_high, 'High priority'),
  urgent('Urgent', Icons.warning, 'Urgent - needs immediate attention');

  const JobUrgency(this.displayName, this.icon, this.description);

  final String displayName;
  final IconData icon;
  final String description;
}
