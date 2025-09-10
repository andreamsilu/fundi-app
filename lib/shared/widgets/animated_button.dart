import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Animated button widget with smooth transitions and loading states
/// Provides consistent button styling across the app with animations
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        widget.isEnabled && !widget.isLoading && widget.onPressed != null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: isEnabled ? widget.onPressed : null,
              child: Container(
                width: widget.width ?? _getButtonWidth(),
                height: widget.height ?? _getButtonHeight(),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(context, isEnabled),
                  borderRadius: BorderRadius.circular(_getBorderRadius()),
                  border: widget.type == ButtonType.outline
                      ? Border.all(
                          color: _getBorderColor(context, isEnabled),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: widget.type == ButtonType.primary && isEnabled
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: _getLoadingSize(),
                          height: _getLoadingSize(),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getTextColor(context, isEnabled),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: _getIconSize(),
                                color: _getTextColor(context, isEnabled),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: _getTextColor(context, isEnabled),
                                fontSize: _getFontSize(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getButtonWidth() {
    switch (widget.size) {
      case ButtonSize.small:
        return 100;
      case ButtonSize.medium:
        return 150;
      case ButtonSize.large:
        return double.infinity;
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.small:
        return 8;
      case ButtonSize.medium:
        return 12;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Color _getBackgroundColor(BuildContext context, bool isEnabled) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    if (!isEnabled) return AppTheme.mediumGray.withValues(alpha: 0.3);

    switch (widget.type) {
      case ButtonType.primary:
        return AppTheme.accentGreen;
      case ButtonType.secondary:
        return AppTheme.primaryGreen;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(BuildContext context, bool isEnabled) {
    if (widget.textColor != null) return widget.textColor!;

    if (!isEnabled) return AppTheme.mediumGray;

    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppTheme.white;
      case ButtonType.outline:
        return AppTheme.primaryGreen;
      case ButtonType.text:
        return AppTheme.accentGreen;
    }
  }

  Color _getBorderColor(BuildContext context, bool isEnabled) {
    if (!isEnabled) return AppTheme.mediumGray;
    return AppTheme.primaryGreen;
  }
}

/// Button types for different styling
enum ButtonType { primary, secondary, outline, text }

/// Button sizes for different use cases
enum ButtonSize { small, medium, large }

