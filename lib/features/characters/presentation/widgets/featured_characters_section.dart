import 'package:flutter/material.dart';
import '../../../../core/core.dart';

import '../../../navigation/navigation.dart';
import '../../domain/domain.dart';
import '../presentation.dart';

class FeaturedCharactersSection extends StatelessWidget {
  final List<Character> featuredCharacters;

  const FeaturedCharactersSection({
    super.key,
    required this.featuredCharacters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FEATURED CHARACTERS', style: AppTextStyles.label),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: featuredCharacters.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredCharacters.length,
                    itemBuilder: (context, index) {
                      final character = featuredCharacters[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 180,
                          child: CharacterCard(
                            character: character,
                            heroTagPrefix: 'featured',
                            onTap: () => AppNavigator.toCharacterDetail(
                              context,
                              character,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Featured characters unavailable',
                      style: AppTextStyles.hint,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
