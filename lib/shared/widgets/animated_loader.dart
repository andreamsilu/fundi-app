import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Animated loader widget with customizable animations
/// Provides various loading states with smooth transitions
class AnimatedLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;
  final LoaderType type;
  final Duration animationDuration;

  const AnimatedLoader({
    super.key,
    this.size = 50,
    this.color,
    this.message,
    this.type = LoaderType.circular,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return _buildLoader();
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoader() {
    final color = widget.color ?? AppTheme.primaryGreen;

    switch (widget.type) {
      case LoaderType.circular:
        return CircularProgressIndicator(
          value: _animation.value,
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        );
      case LoaderType.dots:
        return _buildDotsLoader(color);
      case LoaderType.pulse:
        return _buildPulseLoader(color);
      case LoaderType.bounce:
        return _buildBounceLoader(color);
      case LoaderType.wave:
        return _buildWaveLoader(color);
    }
  }

  Widget _buildDotsLoader(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
        final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPulseLoader(Color color) {
    return Transform.scale(
      scale: 0.5 + (0.5 * _animation.value),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: widget.size * 0.6,
            height: widget.size * 0.6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _buildBounceLoader(Color color) {
    return Transform.translate(
      offset: Offset(0, -10 * (1 - _animation.value)),
      child: Container(
        width: widget.size * 0.3,
        height: widget.size * 0.3,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildWaveLoader(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final delay = index * 0.1;
        final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
        final height = 4 + (16 * (1 - (animationValue - 0.5).abs() * 2));

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Shimmer loading effect for content placeholders
class ShimmerLoader extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? AppTheme.lightGray,
                widget.highlightColor ?? AppTheme.white,
                widget.baseColor ?? AppTheme.lightGray,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value,
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton loader for common UI elements
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    this.type = SkeletonType.text,
    this.width,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ShimmerLoader(child: _buildSkeleton()),
    );
  }

  Widget _buildSkeleton() {
    switch (type) {
      case SkeletonType.text:
        return Container(
          width: width ?? double.infinity,
          height: height ?? 16,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case SkeletonType.circle:
        return Container(
          width: width ?? 50,
          height: height ?? 50,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            shape: BoxShape.circle,
          ),
        );
      case SkeletonType.rectangle:
        return Container(
          width: width ?? double.infinity,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case SkeletonType.card:
        return Container(
          width: width ?? double.infinity,
          height: height ?? 120,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }
}

/// Loading states for different UI elements
class LoadingStates {
  static Widget buildListLoading({int itemCount = 5}) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.all(8),
          child: SkeletonLoader(type: SkeletonType.card),
        );
      },
    );
  }

  static Widget buildGridLoading({int crossAxisCount = 2, int itemCount = 6}) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonLoader(type: SkeletonType.card);
      },
    );
  }

  static Widget buildProfileLoading() {
    return Column(
      children: [
        const SkeletonLoader(type: SkeletonType.circle, width: 80, height: 80),
        const SizedBox(height: 16),
        const SkeletonLoader(type: SkeletonType.text, width: 150, height: 20),
        const SizedBox(height: 8),
        const SkeletonLoader(type: SkeletonType.text, width: 100, height: 16),
        const SizedBox(height: 24),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonLoader(type: SkeletonType.text),
          ),
        ),
      ],
    );
  }
}

/// Loader types
enum LoaderType { circular, dots, pulse, bounce, wave }

/// Skeleton types
enum SkeletonType { text, circle, rectangle, card }

