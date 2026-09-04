import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSelectField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<T> options;
  final String Function(T option) labelBuilder;
  final ValueChanged<T> onSelected;
  final bool enabled;
  final bool searchable;
  final String? Function(T?)? validator;

  const AppSelectField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
    this.enabled = true,
    this.searchable = true,
    this.validator,
  });

  Future<void> _openSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SelectSheet<T>(
        title: label,
        options: options,
        labelBuilder: labelBuilder,
        searchable: searchable,
      ),
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? () => _openSheet(context) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              errorText: state.errorText,
              enabled: enabled,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? labelBuilder(value as T) : 'Pilih $label',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: value != null ? AppColors.ink : AppColors.inkMuted,
                      fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled
                      ? AppColors.inkMuted
                      : AppColors.inkMuted.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectSheet<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final String Function(T) labelBuilder;
  final bool searchable;

  const _SelectSheet({
    required this.title,
    required this.options,
    required this.labelBuilder,
    required this.searchable,
  });

  @override
  State<_SelectSheet<T>> createState() => _SelectSheetState<T>();
}

class _SelectSheetState<T> extends State<_SelectSheet<T>> {
  late List<T> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.options;
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = widget.options
          .where((o) =>
              widget.labelBuilder(o).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.75),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Cari...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.primary.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Flexible(
              child: _filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Gak ketemu, coba kata kunci lain',
                        style: TextStyle(
                            color: AppColors.inkMuted.withValues(alpha: 0.7)),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final option = _filtered[index];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          title: Text(widget.labelBuilder(option)),
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
            SizedBox(height: mediaQuery.padding.bottom + 12),
          ],
        ),
      ),
    );
  }
}