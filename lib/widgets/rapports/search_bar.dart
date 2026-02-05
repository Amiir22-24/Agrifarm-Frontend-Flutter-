// lib/widgets/rapports/search_bar.dart
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;
  final bool isLoading;
  final FocusNode? focusNode;

  const SearchBar({
    Key? key,
    required this.hintText,
    this.initialValue,
    required this.onChanged,
    this.onClear,
    this.showClearButton = true,
    this.isLoading = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        focusNode: focusNode,
        controller: TextEditingController(text: initialValue)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: initialValue?.length ?? 0),
          ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : const Icon(Icons.search),
          suffixIcon: showClearButton && (initialValue?.isNotEmpty ?? false)
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de barre de recherche avec filtre intégré
class SearchBarWithFilter extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final String initialFilter;
  final List<FilterOption> filterOptions;
  final VoidCallback? onClear;
  final bool showClearButton;
  final bool isLoading;

  const SearchBarWithFilter({
    Key? key,
    required this.hintText,
    this.initialValue,
    required this.onSearchChanged,
    required this.onFilterChanged,
    this.initialFilter = 'tous',
    required this.filterOptions,
    this.onClear,
    this.showClearButton = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<SearchBarWithFilter> createState() => _SearchBarWithFilterState();
}

class _SearchBarWithFilterState extends State<SearchBarWithFilter> {
  late TextEditingController _searchController;
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue);
    _selectedFilter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          SearchBar(
            hintText: widget.hintText,
            initialValue: widget.initialValue,
            onChanged: widget.onSearchChanged,
            onClear: () {
              _searchController.clear();
              widget.onSearchChanged('');
              widget.onClear?.call();
            },
            showClearButton: widget.showClearButton,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 12),
          // Filtres par chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.filterOptions.length,
              itemBuilder: (context, index) {
                final option = widget.filterOptions[index];
                final isSelected = _selectedFilter == option.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = option.value;
                      });
                      widget.onFilterChanged(option.value);
                    },
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
          ),
        ],
      ),
    );
  }
}

class FilterOption {
  final String value;
  final String label;
  final IconData? icon;

  const FilterOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

// Widget de recherche avancée
class AdvancedSearchBar extends StatefulWidget {
  final List<AdvancedFilter> filters;
  final ValueChanged<Map<String, String>> onFiltersChanged;
  final VoidCallback? onReset;

  const AdvancedSearchBar({
    Key? key,
    required this.filters,
    required this.onFiltersChanged,
    this.onReset,
  }) : super(key: key);

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final Map<String, String> _selectedFilters = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                const Text(
                  'Filtres avancés',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.onReset != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedFilters.clear();
                      });
                      widget.onFiltersChanged({});
                      widget.onReset?.call();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Réinitialiser'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filter.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedFilters[filter.key],
                      decoration: InputDecoration(
                        hintText: filter.placeholder,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: filter.options.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.value,
                          child: Row(
                            children: [
                              if (option.icon != null) ...[
                                Icon(option.icon, size: 16),
                                const SizedBox(width: 8),
                              ],
                              Text(option.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value == null) {
                            _selectedFilters.remove(filter.key);
                          } else {
                            _selectedFilters[filter.key] = value;
                          }
                        });
                        widget.onFiltersChanged(Map.from(_selectedFilters));
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class AdvancedFilter {
  final String key;
  final String label;
  final String placeholder;
  final List<AdvancedFilterOption> options;

  const AdvancedFilter({
    required this.key,
    required this.label,
    required this.placeholder,
    required this.options,
  });
}

class AdvancedFilterOption {
  final String value;
  final String label;
  final IconData? icon;

  const AdvancedFilterOption({
    required this.value,
    required this.label,
    this.icon,
  });
}
