import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable button widget with consistent styling and animations
/// Provides various button types and states for the application
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final textStyle = _getTextStyle(context);
    final padding = _getPadding();
    final borderRadius = widget.borderRadius ?? _getBorderRadius();

    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              padding: padding,
              decoration: BoxDecoration(
                color: buttonStyle.backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: buttonStyle.border,
                boxShadow: buttonStyle.boxShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          buttonStyle.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: _getIconSize(),
                      color: buttonStyle.textColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (widget.type) {
      case ButtonType.primary:
        return ButtonStyle(
          backgroundColor: widget.backgroundColor ?? context.accentColor,
          textColor: widget.textColor ?? Colors.white,
          border: null,
          boxShadow: [
            BoxShadow(
              color: context.accentColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case ButtonType.secondary:
        return ButtonStyle(
          backgroundColor: Colors.white,
          textColor: widget.textColor ?? context.primaryColor,
          border: Border.all(color: context.primaryColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case ButtonType.text:
        return ButtonStyle(
          backgroundColor: Colors.transparent,
          textColor: widget.textColor ?? context.accentColor,
          border: null,
          boxShadow: null,
        );
      case ButtonType.danger:
        return ButtonStyle(
          backgroundColor: widget.backgroundColor ?? AppTheme.errorColor,
          textColor: widget.textColor ?? Colors.white,
          border: null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }

  TextStyle? _getTextStyle(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final baseStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: buttonStyle.textColor,
      fontWeight: FontWeight.w600,
    );

    switch (widget.size) {
      case ButtonSize.small:
        return baseStyle?.copyWith(fontSize: 12);
      case ButtonSize.medium:
        return baseStyle?.copyWith(fontSize: 14);
      case ButtonSize.large:
        return baseStyle?.copyWith(fontSize: 16);
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
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

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }
}

/// Button style data class
class ButtonStyle {
  final Color backgroundColor;
  final Color textColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  ButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    this.border,
    this.boxShadow,
  });
}

/// Button type enumeration
enum ButtonType { primary, secondary, text, danger }

/// Button size enumeration
enum ButtonSize { small, medium, large }

/// Floating Action Button with custom styling
class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? context.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4,
      child: Icon(icon),
    );
  }
}

/// Icon button with consistent styling
class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double? size;
  final EdgeInsets? padding;

  const AppIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: color ?? context.primaryColor,
      iconSize: size ?? 24,
      padding: padding ?? const EdgeInsets.all(8),
    );
  }
}

/// Button group for multiple related actions
class ButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;
  final double spacing;

  const ButtonGroup({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: children
          .expand((child) => [child, SizedBox(width: spacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}
