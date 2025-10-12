import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Speed Dial FAB Widget
/// Provides quick access to multiple actions from a single FAB
class SpeedDialFAB extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final String? heroTag;

  const SpeedDialFAB({
    super.key,
    required this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.heroTag,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed dial actions
        if (_isOpen) ...[
          ...widget.actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            final delay = index * 50;

            return FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          delay / 250,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Label
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            action.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Button
                      FloatingActionButton(
                        heroTag: 'speed_dial_${action.label}',
                        mini: true,
                        backgroundColor:
                            action.backgroundColor ?? AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          _close();
                          action.onTap();
                        },
                        child: Icon(action.icon, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Main FAB with backdrop
        if (_isOpen)
          GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

        // Main FAB
        FloatingActionButton(
          heroTag: widget.heroTag ?? 'speed_dial_main',
          backgroundColor: widget.backgroundColor ?? AppTheme.primaryGreen,
          foregroundColor: widget.foregroundColor ?? Colors.white,
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0, // 45 degrees when open
            duration: const Duration(milliseconds: 250),
            child: Icon(
              _isOpen ? Icons.close : (widget.icon ?? Icons.add),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

/// Speed Dial Action Model
class SpeedDialAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const SpeedDialAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });
}
