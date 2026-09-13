import 'package:flutter/material.dart';

class AssessmentCard extends StatelessWidget {
  final String assessment;

  const AssessmentCard({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    if (assessment.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF0EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              assessment,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}