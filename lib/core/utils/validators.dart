/// Comprehensive validation utilities for the Fundi App
/// Provides reusable validation methods for forms and data input
class Validators {
  /// Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone number validation regex pattern (Tanzania format)
  static final RegExp _phoneRegex = RegExp(r'^(\+255|0)[0-9]{9}$');

  /// NIDA number validation regex pattern (Tanzania)
  static final RegExp _nidaRegex = RegExp(r'^[0-9]{20}$');

  /// Password strength validation regex pattern
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// Validates email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }

    return null;
  }

  /// Validates simple password (for less strict requirements)
  static String? simplePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  /// Validates phone number (Tanzania format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');

    if (!_phoneRegex.hasMatch(cleanValue)) {
      return 'Please enter a valid Tanzanian phone number (e.g., +255123456789 or 0123456789)';
    }

    return null;
  }

  /// Validates NIDA number
  static String? nidaNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIDA number is required';
    }

    if (!_nidaRegex.hasMatch(value)) {
      return 'NIDA number must be exactly 20 digits';
    }

    return null;
  }

  /// Validates required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates name (first name, last name, etc.)
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }

    if (value.trim().length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters long';
    }

    if (value.trim().length > 50) {
      return '${fieldName ?? 'Name'} must be less than 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(value.trim())) {
      return '${fieldName ?? 'Name'} can only contain letters, spaces, hyphens, and periods';
    }

    return null;
  }

  /// Validates description or text content
  static String? description(
    String? value, {
    String? fieldName,
    int? maxLength,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Description'} is required';
    }

    final maxLen = maxLength ?? 500;
    if (value.trim().length > maxLen) {
      return '${fieldName ?? 'Description'} must be less than $maxLen characters';
    }

    return null;
  }

  /// Validates budget amount
  static String? budget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget is required';
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Budget must be greater than 0';
    }

    if (amount > 10000000) {
      // 10 million TZS
      return 'Budget cannot exceed 10,000,000 TZS';
    }

    return null;
  }

  /// Validates location
  static String? location(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }

    if (value.trim().length < 3) {
      return 'Location must be at least 3 characters long';
    }

    return null;
  }

  /// Validates job title
  static String? jobTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Job title is required';
    }

    if (value.trim().length < 3) {
      return 'Job title must be at least 3 characters long';
    }

    if (value.trim().length > 100) {
      return 'Job title must be less than 100 characters';
    }

    return null;
  }

  /// Validates confirmation password
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates file upload
  static String? fileUpload(
    String? filePath, {
    List<String>? allowedExtensions,
    int? maxSizeMB,
  }) {
    if (filePath == null || filePath.isEmpty) {
      return 'Please select a file';
    }

    // Check file extension
    if (allowedExtensions != null) {
      final extension = filePath.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return 'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}';
      }
    }

    // Check file size (if maxSizeMB is provided)
    if (maxSizeMB != null) {
      // Note: This is a basic check. In a real app, you'd check the actual file size
      // For now, we'll just validate the extension
    }

    return null;
  }

  /// Validates date
  static String? date(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Date is required' : null;
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validates future date
  static String? futureDate(String? value, {bool isRequired = true}) {
    final dateValidation = date(value, isRequired: isRequired);
    if (dateValidation != null) return dateValidation;

    if (value != null && value.isNotEmpty) {
      try {
        final selectedDate = DateTime.parse(value);
        final now = DateTime.now();

        if (selectedDate.isBefore(now)) {
          return 'Date must be in the future';
        }

        return null;
      } catch (e) {
        return 'Please enter a valid date';
      }
    }

    return null;
  }

  /// Validates age (for user registration)
  static String? age(String? value, {int minAge = 18, int maxAge = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }

    if (age > maxAge) {
      return 'Please enter a valid age';
    }

    return null;
  }

  /// Validates rating (1-5 stars)
  static String? rating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Rating is required';
    }

    final rating = double.tryParse(value);
    if (rating == null) {
      return 'Please enter a valid rating';
    }

    if (rating < 1 || rating > 5) {
      return 'Rating must be between 1 and 5';
    }

    return null;
  }

  /// Validates multiple fields at once
  static Map<String, String?> validateFields(Map<String, String?> fields) {
    final errors = <String, String?>{};

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      String? error;

      switch (fieldName.toLowerCase()) {
        case 'email':
          error = email(value);
          break;
        case 'password':
          error = password(value);
          break;
        case 'phone':
        case 'phonenumber':
          error = phoneNumber(value);
          break;
        case 'nida':
        case 'nidanumber':
          error = nidaNumber(value);
          break;
        case 'firstname':
        case 'lastname':
        case 'name':
          error = name(value, fieldName: fieldName);
          break;
        case 'description':
          error = description(value, fieldName: fieldName);
          break;
        case 'budget':
          error = budget(value);
          break;
        case 'location':
          error = location(value);
          break;
        case 'jobtitle':
          error = jobTitle(value);
          break;
        default:
          error = required(value, fieldName: fieldName);
      }

      if (error != null) {
        errors[fieldName] = error;
      }
    }

    return errors;
  }
}
