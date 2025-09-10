import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// OTP Input Widget with 6 boxes and clipboard autofill support
/// Provides a modern, accessible OTP input experience
class OtpInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool autofocus;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const OtpInputWidget({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = true,
    this.validator,
    this.controller,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late String _otpValue;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _otpValue = '';
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());

    // Set up focus listeners
    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          _selectAllText(i);
        }
      });
    }

    // Set up text change listeners
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() {
        _onTextChanged(i);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _selectAllText(int index) {
    _controllers[index].selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controllers[index].text.length,
    );
  }

  void _onTextChanged(int index) {
    final text = _controllers[index].text;

    // Handle single character input
    if (text.length == 1) {
      _updateOtpValue();
      _moveToNext(index);
    } else if (text.length > 1) {
      // Handle paste or multiple character input
      _handlePaste(text, index);
    } else if (text.isEmpty) {
      _updateOtpValue();
      _moveToPrevious(index);
    }
  }

  void _handlePaste(String text, int startIndex) {
    // Remove non-numeric characters
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.isEmpty) return;

    // Fill the remaining boxes with the pasted text
    for (
      int i = 0;
      i < cleanText.length && (startIndex + i) < widget.length;
      i++
    ) {
      _controllers[startIndex + i].text = cleanText[i];
    }

    _updateOtpValue();

    // Move focus to the last filled box or the last box
    final lastFilledIndex = (startIndex + cleanText.length - 1).clamp(
      0,
      widget.length - 1,
    );
    _focusNodes[lastFilledIndex].requestFocus();
  }

  void _updateOtpValue() {
    final newValue = _controllers.map((controller) => controller.text).join();
    if (newValue != _otpValue) {
      setState(() {
        _otpValue = newValue;
      });
      widget.onChanged?.call(newValue);

      if (newValue.length == widget.length) {
        widget.onCompleted?.call(newValue);
      }
    }
  }

  void _moveToNext(int currentIndex) {
    if (currentIndex < widget.length - 1) {
      _focusNodes[currentIndex + 1].requestFocus();
    } else {
      _focusNodes[currentIndex].unfocus();
    }
  }

  void _moveToPrevious(int currentIndex) {
    if (currentIndex > 0) {
      _focusNodes[currentIndex - 1].requestFocus();
    }
  }

  void _onKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (index < widget.length - 1) {
          _focusNodes[index + 1].requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) => _buildOtpBox(index)),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? context.primaryColor
              : AppTheme.lightGray,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: widget.enabled
            ? (_focusNodes[index].hasFocus
                  ? context.primaryColor.withOpacity(0.05)
                  : Colors.white)
            : AppTheme.lightGray.withOpacity(0.3),
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyEvent(event, index),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          autofocus: widget.autofocus && index == 0,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: '0',
            hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.mediumGray,
              fontWeight: FontWeight.w400,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: (value) {
            // This is handled by the controller listener
          },
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(_otpValue);
            }
            return null;
          },
        ),
      ),
    );
  }

  /// Get the current OTP value
  String get value => _otpValue;

  /// Clear all input fields
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _otpValue = '';
    _focusNodes[0].requestFocus();
  }

  /// Set the OTP value programmatically
  void setValue(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = i < cleanValue.length ? cleanValue[i] : '';
    }
    _updateOtpValue();
  }
}
