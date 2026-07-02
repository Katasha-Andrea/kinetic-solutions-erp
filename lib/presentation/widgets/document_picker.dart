import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/app_document.dart';

class DocumentPicker extends StatefulWidget {
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;
  final String? categoryFilter;

  const DocumentPicker({
    super.key,
    required this.selectedIds,
    required this.onChanged,
    this.categoryFilter,
  });

  @override
  State<DocumentPicker> createState() => _DocumentPickerState();
}

class _DocumentPickerState extends State<DocumentPicker> {
  List<AppDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final all = LocalDatabase.getDocuments();
    setState(() {
      _documents = all
          .where((d) => widget.categoryFilter == null || d.category == widget.categoryFilter)
          .toList();
      _isLoading = false;
    });
  }

  void _toggleSelection(String id) {
    final newList = List<String>.from(widget.selectedIds);
    if (newList.contains(id)) {
      newList.remove(id);
    } else {
      newList.add(id);
    }
    widget.onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_documents.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No documents available', style: TextStyle(color: AppTheme.textSecondary)),
          )
        else
          Wrap(
            spacing: 8,
            children: _documents.map((doc) {
              final isSelected = widget.selectedIds.contains(doc.id);
              return FilterChip(
                label: Text(doc.title),
                selected: isSelected,
                onSelected: (_) => _toggleSelection(doc.id),
                backgroundColor: AppTheme.bgColor,
                selectedColor: AppTheme.primary50,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}