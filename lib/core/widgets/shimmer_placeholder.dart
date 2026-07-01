import 'package:flutter/material.dart';

class ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-2.0 + _controller.value * 4.0, -1.0),
              end: Alignment(0.0 + _controller.value * 4.0, 1.0),
              colors: const [
                Color(0xFF1E1E1E),
                Color(0xFF2D2D2D),
                Color(0xFF1E1E1E),
              ],
            ),
          ),
        );
      },
    );
  }
}
