import 'package:flutter/material.dart';

import '../../../../../core/widgets/trading_ui_tokens.dart';

class BehaviorTagPicker extends StatefulWidget {
  const BehaviorTagPicker({
    required this.tags,
    required this.selected,
    required this.onToggle,
    required this.searchHint,
    required this.clearSearchTooltip,
    super.key,
  });

  final List<String> tags;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final String searchHint;
  final String clearSearchTooltip;

  @override
  State<BehaviorTagPicker> createState() => _BehaviorTagPickerState();
}

class _BehaviorTagPickerState extends State<BehaviorTagPicker> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleTags = normalizedQuery.isEmpty
        ? widget.tags
        : widget.tags
            .where((tag) => tag.toLowerCase().contains(normalizedQuery))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: widget.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close),
                    tooltip: widget.clearSearchTooltip,
                  ),
          ),
        ),
        const SizedBox(height: TradingUiSpacing.sm),
        Wrap(
          spacing: TradingUiSpacing.sm,
          runSpacing: TradingUiSpacing.sm,
          children: visibleTags
              .map(
                (tag) => FilterChip(
                  label: Text(tag),
                  selected: widget.selected.contains(tag),
                  onSelected: (_) => widget.onToggle(tag),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
