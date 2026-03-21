import 'package:flutter/material.dart';

class GPABadge extends StatelessWidget {
  final double gpa;

  const GPABadge({super.key, required this.gpa});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'GPA',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade200,
            ),
          ),
          Text(
            '$gpa',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
