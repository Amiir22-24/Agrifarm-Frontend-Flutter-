// lib/widgets/rapports/sort_button.dart
import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {
  final String currentSort;
  final bool isDescending;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<bool> onSortOrderChanged;
  final List<SortOption> sortOptions;

  const SortButton({
    Key? key,
    required this.currentSort,
    required this.isDescending,
    required this.onSortChanged,
    required this.onSortOrderChanged,
    required this.sortOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.sort,
        color: Theme.of(context).primaryColor,
      ),
      tooltip: 'Trier',
      onSelected: (value) {
        if (value == 'asc' || value == 'desc') {
          onSortOrderChanged(value == 'desc');
        } else {
          onSortChanged(value);
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        
        // Section des options de tri
        for (final option in sortOptions) {
          items.add(
            PopupMenuItem<String>(
              value: option.value,
              child: Row(
                children: [
                  Icon(option.icon),
                  const SizedBox(width: 12),
                  Text(option.label),
                  if (currentSort == option.value)
                    const Spacer(),
                  if (currentSort == option.value)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        }

        // Séparateur
        items.add(const PopupMenuDivider());

        // Options d'ordre
        items.add(
          PopupMenuItem<String>(
            value: 'asc',
            child: Row(
              children: [
                const Icon(Icons.arrow_upward),
                const SizedBox(width: 12),
                const Text('Croissant'),
                const Spacer(),
                if (!isDescending)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
              ],
            ),
          ),
        );

        items.add(
          PopupMenuItem<String>(
            value: 'desc',
            child: Row(
              children: [
                const Icon(Icons.arrow_downward),
                const SizedBox(width: 12),
                const Text('Décroissant'),
                const Spacer(),
                if (isDescending)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
              ],
            ),
          ),
        );

        return items;
      },
    );
  }
}

class SortOption {
  final String value;
  final String label;
  final IconData icon;

  const SortOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

// Widget de header de colonne triable
class SortableColumnHeader extends StatelessWidget {
  final String label;
  final String sortKey;
  final String? currentSort;
  final bool isDescending;
  final VoidCallback onTap;
  final IconData? defaultIcon;

  const SortableColumnHeader({
    Key? key,
    required this.label,
    required this.sortKey,
    this.currentSort,
    required this.isDescending,
    required this.onTap,
    this.defaultIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSorted = currentSort == sortKey;
    
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSorted ? FontWeight.bold : FontWeight.normal,
              color: isSorted ? Theme.of(context).primaryColor : null,
            ),
          ),
          const SizedBox(width: 4),
          if (isSorted)
            Icon(
              isDescending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              color: Theme.of(context).primaryColor,
              size: 18,
            )
          else if (defaultIcon != null)
            Icon(
              defaultIcon,
              size: 16,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}

// Widget de tableau avec tri pour les rapports
class SortableRapportsTable extends StatelessWidget {
  final List<RapportTableRow> rows;
  final List<TableColumn> columns;
  final String? currentSort;
  final bool isDescending;
  final Function(String) onSortChanged;
  final Function(bool) onSortOrderChanged;

  const SortableRapportsTable({
    Key? key,
    required this.rows,
    required this.columns,
    this.currentSort,
    required this.isDescending,
    required this.onSortChanged,
    required this.onSortOrderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header du tableau
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: columns.map((column) {
                return Expanded(
                  flex: column.flex,
                  child: SortableColumnHeader(
                    label: column.label,
                    sortKey: column.sortKey,
                    currentSort: currentSort,
                    isDescending: isDescending,
                    onTap: () => onSortChanged(column.sortKey),
                    defaultIcon: column.icon,
                  ),
                );
              }).toList(),
            ),
          ),
          // Contenu du tableau
          ...rows.map((row) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: row.cells.map((cell) {
                  return Expanded(
                    flex: cell.flex,
                    child: cell.child,
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class RapportTableRow {
  final List<TableCell> cells;

  const RapportTableRow({
    required this.cells,
  });
}

class TableColumn {
  final String label;
  final String sortKey;
  final int flex;
  final IconData? icon;

  const TableColumn({
    required this.label,
    required this.sortKey,
    this.flex = 1,
    this.icon,
  });
}

class TableCell {
  final int flex;
  final Widget child;

  const TableCell({
    required this.flex,
    required this.child,
  });
}

// Widget de tri rapide avec chips
class QuickSortChips extends StatelessWidget {
  final List<SortChip> sortChips;
  final String? selectedSort;
  final ValueChanged<String> onSortSelected;

  const QuickSortChips({
    Key? key,
    required this.sortChips,
    this.selectedSort,
    required this.onSortSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortChips.length,
        itemBuilder: (context, index) {
          final chip = sortChips[index];
          final isSelected = selectedSort == chip.value;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(chip.label),
              selected: isSelected,
              onSelected: (_) => onSortSelected(chip.value),
              avatar: chip.icon != null ? Icon(chip.icon, size: 16) : null,
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SortChip {
  final String value;
  final String label;
  final IconData? icon;

  const SortChip({
    required this.value,
    required this.label,
    this.icon,
  });
}
