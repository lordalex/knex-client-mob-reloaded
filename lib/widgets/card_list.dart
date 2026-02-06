import 'package:flutter/material.dart';

/// Placeholder card list widget.
///
/// Will be replaced in Phase 3 with the scrollable location list
/// that renders [CardItem] widgets from the locations provider.
class CardList extends StatelessWidget {
  final List<String> items;
  final void Function(int index)? onItemTap;

  const CardList({super.key, this.items = const [], this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No items'));
    }

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
          onTap: onItemTap != null ? () => onItemTap!(index) : null,
        );
      },
    );
  }
}
