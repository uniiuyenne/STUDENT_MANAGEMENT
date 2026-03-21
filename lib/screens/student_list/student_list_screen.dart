import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentmanager/widgets/common/student_card.dart';
import 'package:studentmanager/widgets/filters/filter_bottom_sheet.dart';
import 'package:studentmanager/widgets/common/action_icon.dart';
import 'package:studentmanager/widgets/common/filter_header_widget.dart';
import 'package:studentmanager/utils/animation_helper.dart';
import '../../providers/student_provider.dart';
import '../../providers/theme_provider.dart';
import '../student_detail/student_detail_screen.dart';
import '../add_edit_student/add_edit_student_screen.dart';
import '../statistics/statistics_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _classFilter = '';
  String _deptFilter = '';
  double? _gpaFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload data when app is resumed (coming back from other screens)
      context.read<StudentProvider>().fetchStudents();
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterBottomSheet(
        initialClass: _classFilter,
        initialDept: _deptFilter,
        initialGpa: _gpaFilter,
        onApply: (classFilter, deptFilter, gpaFilter) {
          setState(() {
            _classFilter = classFilter;
            _deptFilter = deptFilter;
            _gpaFilter = gpaFilter;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final filteredStudents = provider.getFilteredStudents(
      _query,
      _classFilter,
      _deptFilter,
      _gpaFilter,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Trang chu',
          onPressed: () {
            setState(() {
              _query = '';
              _classFilter = '';
              _deptFilter = '';
              _gpaFilter = null;
              _searchController.clear();
            });
            context.read<StudentProvider>().fetchStudents();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: const Text('TH5 - Student Manager - Nhóm 8'),
        actions: [
          ActionIcon(
            icon: Icons.bar_chart,
            tooltip: 'Statistics',
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              Navigator.push(
                context,
                AnimationHelper.createSlideTransition(
                  const StatisticsScreen(),
                ),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ActionIcon(
                icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                backgroundColor: Colors.orange,
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          ActionIcon(
            icon: Icons.add,
            tooltip: 'Add student',
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                AnimationHelper.createSlideTransition(
                  const AddEditStudentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên hoặc mã sinh viên',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          // Sticky Filter Header
          FilterHeaderWidget(
            classFilter: _classFilter,
            deptFilter: _deptFilter,
            gpaFilter: _gpaFilter,
            studentCount: filteredStudents.length,
            onFilterTap: _openFilterSheet,
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.fetchStudents(),
                    child: filteredStudents.isEmpty
                        ? const Center(
                            child: Text(
                              'Không tìm thấy sinh viên nào.',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return StudentCard(
                                student: student,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    AnimationHelper.createSlideTransition(
                                      StudentDetailScreen(student: student),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
