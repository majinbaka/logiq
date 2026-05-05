import 'package:flutter/material.dart';

class StrategyListTile extends StatelessWidget {
  const StrategyListTile({
    required this.name,
    required this.description,
    required this.isActive,
    this.onTap,
    super.key,
  });

  final String name;
  final String description;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isActive ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        onTap: onTap,
        title: Text(name),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(isActive ? 'Active' : 'Archived'),
      ),
    );
  }
}
