import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class EmptySearchState extends StatelessWidget {
  const EmptySearchState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No characters found',
            style: AppTextStyles.label.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text('Try searching for another name', style: AppTextStyles.hint),
        ],
      ),
    );
  }
}
