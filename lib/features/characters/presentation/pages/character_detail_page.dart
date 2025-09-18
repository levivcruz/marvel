import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../navigation/navigation.dart';
import '../../../../core/core.dart';
import '../../domain/domain.dart';
import '../presentation.dart';

class CharacterDetailPage extends StatelessWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              showBackButton: true,
              onBackPressed: () => AppNavigator.goBack(context),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Hero(
                tag: 'character_${character.id}',
                child: CachedNetworkImage(
                  imageUrl: character.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: AppLoading(size: 32)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(character.name, style: AppTextStyles.header),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BIOGRAPHY', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 8),
                  Text(
                    character.description.isNotEmpty
                        ? character.description
                        : 'No biography available for this character.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (character.comics.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildInfoSection('COMICS', character.comics),
            ),
          if (character.series.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildInfoSection('SERIES', character.series),
            ),
          if (character.stories.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildInfoSection('STORIES', character.stories),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          ...items
              .take(5)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(child: Text(item, style: AppTextStyles.body)),
                    ],
                  ),
                ),
              ),
          if (items.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${items.length - 5} more',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
