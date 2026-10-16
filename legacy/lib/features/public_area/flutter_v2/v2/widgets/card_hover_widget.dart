import 'package:flutter/material.dart';

class HoverCardWidget extends StatefulWidget {
  final Widget child;
  const HoverCardWidget({super.key, required this.child});

  @override
  State<HoverCardWidget> createState() => _HoverCardWidgetState();
}

class _HoverCardWidgetState extends State<HoverCardWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovering ? (Matrix4.identity()..translate(0, -5, 0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _isHovering ? Colors.black.withAlpha(35) : Colors.black.withAlpha(13),
              spreadRadius: _isHovering ? 4 : 2,
              blurRadius: _isHovering ? 20 : 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
