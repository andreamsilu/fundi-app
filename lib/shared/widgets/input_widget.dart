import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Reusable input field widget with consistent styling and validation
/// Provides various input types and states for the application
class AppInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final InputType type;

  const AppInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.type = InputType.text,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Input field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppTheme.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.mediumGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.mediumGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.mediumGray),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: _toggleObscureText,
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.mediumGray,
        ),
      );
    }
    return widget.suffixIcon;
  }
}

/// Input type enumeration
enum InputType { text, email, password, phone, number, multiline, search }

/// Specialized input fields for common use cases
class EmailInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isRequired;

  const EmailInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      label: label ?? 'Email',
      hint: hint ?? 'Enter your email address',
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: validator ?? _validateEmail,
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Email is required' : null;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}

class PasswordInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isRequired;

  const PasswordInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.isRequired = false,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  @override
  Widget build(BuildContext context) {
    return AppInputField(
      label: widget.label ?? 'Password',
      hint: widget.hint ?? 'Enter your password',
      initialValue: widget.initialValue,
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: widget.validator ?? _validatePassword,
      onChanged: widget.onChanged,
      isRequired: widget.isRequired,
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return widget.isRequired ? 'Password is required' : null;
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }
}

class PhoneInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isRequired;

  const PhoneInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      label: label ?? 'Phone Number',
      hint: hint ?? 'Enter your phone number',
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      validator: validator ?? _validatePhone,
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Phone number is required' : null;
    }

    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}

class SearchInputField extends StatelessWidget {
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchInputField({
    super.key,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      hint: hint ?? 'Search...',
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
              icon: const Icon(Icons.clear),
            )
          : null,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
