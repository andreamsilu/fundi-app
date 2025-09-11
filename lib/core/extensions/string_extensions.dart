import 'package:flutter/material.dart';

/// Extension methods for String class
extension StringExtensions on String {
  /// Convert string to Color based on status
  Color toColor() {
    switch (toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'in_progress':
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.yellow;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'withdrawn':
        return Colors.grey;
      case 'active':
        return Colors.green;
      case 'verified':
        return Colors.blue;
      case 'suspended':
        return Colors.red;
      case 'deleted':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get display name for status strings
  String get displayName {
    switch (toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      case 'active':
        return 'Active';
      case 'verified':
        return 'Verified';
      case 'suspended':
        return 'Suspended';
      case 'deleted':
        return 'Deleted';
      default:
        return replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
        ).join(' ');
    }
  }

  /// Capitalize first letter of each word
  String get capitalize {
    if (isEmpty) return this;
    return split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : word
    ).join(' ');
  }

  /// Check if string is a valid email
  bool get isEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isPhoneNumber {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(replaceAll(' ', '').replaceAll('-', ''));
  }

  /// Get initials from name
  String get initials {
    if (isEmpty) return '';
    final words = split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return words.take(2).map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() : ''
    ).join('');
  }

  /// Truncate string to specified length
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string is null or empty
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }
}
