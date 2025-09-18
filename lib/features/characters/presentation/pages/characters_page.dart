import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../injection/injection.dart' as di;
import '../../../../services/services.dart';
import '../presentation.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  final _analytics = di.sl<AnalyticsServiceInterface>();
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    _analytics.trackScreen('characters_list');

    final startTime = DateTime.now();

    context.read<CharacterBloc>().add(GetCharactersEvent());
    context.read<CharacterBloc>().add(GetFeaturedCharactersEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      _analytics.trackEvent(
        eventName: 'page_load_time',
        parameters: {'page_name': 'characters_list', 'load_time_ms': loadTime},
      );
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    context.read<CharacterBloc>().add(
      ScrollEvent(
        scrollController.position.pixels,
        scrollController.position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) => _CharactersPageContent(
          state: state,
          scrollController: scrollController,
          onRetryError: _onRetryError,
          onRefresh: _onRefresh,
          onLoadMore: () =>
              context.read<CharacterBloc>().add(LoadMoreCharactersEvent()),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<CharacterBloc>().add(GetCharactersEvent());
  }

  void _onRetryError() {
    context.read<CharacterBloc>().add(GetCharactersEvent());
    context.read<CharacterBloc>().add(GetFeaturedCharactersEvent());
  }
}

class _CharactersPageContent extends StatelessWidget {
  final CharacterState state;
  final ScrollController scrollController;
  final VoidCallback onRetryError;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const _CharactersPageContent({
    required this.state,
    required this.scrollController,
    required this.onRetryError,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (state is CharacterLoading) {
      return const AppLoading();
    }

    if (state is CharacterError) {
      final errorState = state as CharacterError;
      return CustomErrorWidget(
        error: errorState,
        onRetry: errorState.canRetry ? onRetryError : null,
      );
    }

    if (state is CharacterLoaded) {
      final loadedState = state as CharacterLoaded;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              const SliverToBoxAdapter(child: AppHeader()),

              SliverToBoxAdapter(
                child: FeaturedCharactersSection(
                  featuredCharacters: loadedState.featuredCharacters,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: SearchWidget(scrollController: scrollController),
                ),
              ),

              CharactersGridSection(state: loadedState, onLoadMore: onLoadMore),
            ],
          ),
        ),
      );
    }

    return const Center(child: AppLoading());
  }
}
