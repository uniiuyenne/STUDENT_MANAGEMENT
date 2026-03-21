import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const ActionIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: CircleAvatar(
          radius: 18,
          backgroundColor: backgroundColor,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
