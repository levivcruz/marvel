import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../presentation.dart';

class SearchWidget extends StatefulWidget {
  final ScrollController? scrollController;

  const SearchWidget({super.key, this.scrollController});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final TextEditingController _controller;
  Timer? _debounce;
  final GlobalKey _fieldKey = GlobalKey();
  late final FocusNode _focusNode;
  double? _previousScrollOffset;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus &&
          _previousScrollOffset != null &&
          widget.scrollController != null) {
        final controller = widget.scrollController!;
        final target = _previousScrollOffset!.clamp(
          0.0,
          controller.position.maxScrollExtent,
        );
        controller.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        _previousScrollOffset = null;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<CharacterBloc>().add(SearchCharactersEvent(value));
    });
  }

  void _clearSearch() {
    _controller.clear();
    _debounce?.cancel();
    context.read<CharacterBloc>().add(SearchCharactersEvent(''));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('MARVEL CHARACTERS LIST', style: AppTextStyles.label),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            key: _fieldKey,
            focusNode: _focusNode,
            controller: _controller,
            onChanged: _onSearchChanged,

            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                final ctx = _fieldKey.currentContext;
                if (ctx != null) {
                  if (widget.scrollController != null) {
                    _previousScrollOffset = widget.scrollController!.offset;
                  }

                  Scrollable.ensureVisible(
                    ctx,
                    alignment: 0.05,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            },

            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimaryLight,
            ),

            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textPrimaryLight,
                size: 20,
              ),

              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black54,
                        size: 18,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,

              hintText: 'Search characters',
              hintStyle: AppTextStyles.hint,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),

            textInputAction: TextInputAction.search,
          ),
        ),
      ],
    );
  }
}
