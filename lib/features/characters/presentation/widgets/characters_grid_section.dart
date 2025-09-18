import 'package:flutter/material.dart';

import '../../../navigation/navigation.dart';
import '../presentation.dart';

class CharactersGridSection extends StatelessWidget {
  final CharacterLoaded state;
  final VoidCallback onLoadMore;

  const CharactersGridSection({
    super.key,
    required this.state,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (state.characters.isEmpty && state.searchQuery.isNotEmpty) {
      return const SliverToBoxAdapter(child: EmptySearchState());
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.characters.length,
            itemBuilder: (context, index) {
              final character = state.characters[index];
              return CharacterCard(
                character: character,
                heroTagPrefix: 'list',
                onTap: () => AppNavigator.toCharacterDetail(context, character),
              );
            },
          ),

          if (!state.hasReachedMax || state.inlineError != null)
            _LoadingOrErrorWidget(state: state, onLoadMore: onLoadMore),
        ]),
      ),
    );
  }
}

class _LoadingOrErrorWidget extends StatelessWidget {
  final CharacterLoaded state;
  final VoidCallback onLoadMore;

  const _LoadingOrErrorWidget({required this.state, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    if (state.inlineError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: InlineErrorWidget(
          error: state.inlineError!,
          onRetry: state.inlineError!.canRetry ? onLoadMore : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: AppLoading(size: 24)),
    );
  }
}
