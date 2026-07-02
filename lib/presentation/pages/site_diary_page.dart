import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/site_diary.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/presentation/pages/site_diary_form_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class SiteDiaryPage extends StatefulWidget {
  final AppUser currentUser;

  const SiteDiaryPage({super.key, required this.currentUser});

  @override
  State<SiteDiaryPage> createState() => _SiteDiaryPageState();
}

class _SiteDiaryPageState extends State<SiteDiaryPage> {
  List<SiteDiary> _allDiaries = [];
  List<SiteDiary> _filteredDiaries = [];
  List<Project> _projects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedProject = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final diaries = LocalDatabase.getSiteDiaries();
    final projects = LocalDatabase.getProjects();
    setState(() {
      _allDiaries = diaries;
      _filteredDiaries = diaries;
      _projects = projects;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredDiaries = _allDiaries.where((d) {
        final matchesSearch = _searchQuery.isEmpty ||
            d.woNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.supervisorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.workCompleted.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesProject = _selectedProject == 'All' || d.projectId == _selectedProject;
        return matchesSearch && matchesProject;
      }).toList();
    });
  }

  String _getProjectName(String projectId) {
    final p = _projects.firstWhere((p) => p.id == projectId, orElse: () => throw Exception("Not found"));
    return p?.name ?? 'Unknown';
  }

  Future<void> _navigateToForm({SiteDiary? diary}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SiteDiaryFormPage(
          currentUser: widget.currentUser,
          diary: diary,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteDiary(SiteDiary diary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Diary Entry'),
        content: Text('Delete entry for ${DateFormat('dd MMM yyyy').format(diary.date)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteSiteDiary(diary.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditProjects;
    final total = _allDiaries.length;
    final submitted = _allDiaries.where((d) => d.isSubmitted).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Site Diary'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToForm(),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatCard('Total', total, Colors.brown.shade700),
                const SizedBox(width: 12),
                _buildStatCard('Submitted', submitted, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Draft', total - submitted, AppTheme.warningColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by WO, supervisor...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedProject,
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All Projects')),
                    ..._projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProject = value!;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _filteredDiaries.isEmpty
                    ? const Center(child: Text('No diary entries'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDiaries.length,
                        itemBuilder: (ctx, i) {
                          final d = _filteredDiaries[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: d.isSubmitted ? AppTheme.primary50 : AppTheme.warningLight,
                                child: Icon(
                                  d.isSubmitted ? Icons.check_circle : Icons.edit,
                                  color: d.isSubmitted ? AppTheme.primary500 : AppTheme.warningColor,
                                ),
                              ),
                              title: Text(
                                'WO: ${d.woNumber}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Project: ${_getProjectName(d.projectId)}'),
                                  Text('Date: ${DateFormat('dd MMM yyyy').format(d.date)} • Supervisor: ${d.supervisorName}'),
                                  if (d.workCompleted.isNotEmpty)
                                    Text('Work: ${d.workCompleted}', maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(d.isSubmitted ? 'Submitted' : 'Draft'),
                                    backgroundColor: d.isSubmitted ? AppTheme.primary50 : AppTheme.warningLight,
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(diary: d);
                                        else if (value == 'delete') _deleteDiary(d);
                                      },
                                      itemBuilder: (ctx) => const [
                                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                                      ],
                                    ),
                                ],
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

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (ctx, i) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: const ListTile(
            leading: CircleAvatar(),
            title: SizedBox(height: 16, width: double.infinity),
            subtitle: SizedBox(height: 48, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
