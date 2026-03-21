import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/student_provider.dart';
import '../../constants/app_constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  String _filterType = 'all';
  String? _selectedClass;
  String? _selectedDepartment;
  late TextEditingController _classController;
  late TextEditingController _departmentController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController(text: _selectedClass ?? '');
    _departmentController =
        TextEditingController(text: _selectedDepartment ?? '');
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _classController.dispose();
    _departmentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredStudents(StudentProvider provider) {
    if (_filterType == 'class' && _selectedClass != null) {
      return provider.students
          .where((s) => s.className == _selectedClass)
          .toList();
    } else if (_filterType == 'department' && _selectedDepartment != null) {
      return provider.students
          .where((s) => s.department == _selectedDepartment)
          .toList();
    } else {
      return provider.students;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final filteredStudents = _getFilteredStudents(provider);
    final stats = _calculateStats(filteredStudents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê sinh viên'),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade100.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            // Filter Buttons (Toàn bộ, Theo Lớp, Theo Khoa)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton('Toàn bộ', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Theo Lớp', 'class'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Theo Khoa', 'department'),
                  ],
                ),
              ),
            ),
            // Selector for class or department
            if (_filterType == 'class')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Autocomplete<String>(
                  initialValue: TextEditingValue(text: _selectedClass ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return AppConstants.classes;
                    }
                    return AppConstants.classes.where(
                      (option) => option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, controller, focusNode,
                      onFieldSubmitted) {
                    _classController = controller;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Chọn hoặc nhập lớp',
                        prefixIcon: Icon(Icons.class_),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value;
                        });
                      },
                    );
                  },
                  onSelected: (selection) {
                    setState(() {
                      _selectedClass = selection;
                      _classController.text = selection;
                    });
                  },
                ),
              )
            else if (_filterType == 'department')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Autocomplete<String>(
                  initialValue:
                      TextEditingValue(text: _selectedDepartment ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return AppConstants.departments;
                    }
                    return AppConstants.departments.where(
                      (option) => option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, controller, focusNode,
                      onFieldSubmitted) {
                    _departmentController = controller;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Chọn hoặc nhập khoa',
                        prefixIcon: Icon(Icons.apartment),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                      },
                    );
                  },
                  onSelected: (selection) {
                    setState(() {
                      _selectedDepartment = selection;
                      _departmentController.text = selection;
                    });
                  },
                ),
              ),
            // Tabs (Phân loại, Biểu đồ, Chi tiết)
            Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '📊 Phân loại', icon: Icon(Icons.category)),
                  Tab(text: '📈 Biểu đồ', icon: Icon(Icons.pie_chart)),
                  Tab(text: '📋 Chi tiết', icon: Icon(Icons.table_chart)),
                ],
              ),
            ),
            // TabBarView Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Classification
                  _buildClassificationTab(context, stats),
                  // Tab 2: Chart
                  _buildChartTab(context, stats),
                  // Tab 3: Details
                  _buildDetailsTab(context, stats),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationTab(
      BuildContext context, Map<String, dynamic> stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main Stats Card
        Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade400],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Tổng Quan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '👥',
                      'Tổng cộng',
                      '${stats['total']}',
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '📊 Phân loại sinh viên',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: '⭐⭐⭐⭐',
          title: 'Sinh viên Xuất sắc',
          count: stats['excellent'] ?? 0,
          color: Colors.green,
          total: stats['total'] ?? 1,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: '⭐⭐⭐',
          title: 'Sinh viên Giỏi',
          count: stats['verygood'] ?? 0,
          color: Colors.blue,
          total: stats['total'] ?? 1,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: '⭐⭐',
          title: 'Sinh viên Khá',
          count: stats['good'] ?? 0,
          color: Colors.orange,
          total: stats['total'] ?? 1,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: '⭐',
          title: 'Sinh viên Trung bình',
          count: stats['average'] ?? 0,
          color: Colors.red,
          total: stats['total'] ?? 1,
        ),
      ],
    );
  }

  Widget _buildChartTab(BuildContext context, Map<String, dynamic> stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Biểu đồ phân bố',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPieChart(stats),
                const SizedBox(height: 12),
                _buildLegend(stats),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context, Map<String, dynamic> stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📈 Chi tiết thống kê',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder(
                        horizontalInside:
                            BorderSide(color: Colors.grey.shade300),
                        verticalInside:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      columnWidths: const {
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(80),
                        2: FixedColumnWidth(80),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                          ),
                          children: [
                            _buildTableCell('Xếp loại', isHeader: true),
                            _buildTableCell('Số lượng', isHeader: true),
                            _buildTableCell('Phần trăm', isHeader: true),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('Xuất sắc'),
                            _buildTableCell('${stats['excellent'] ?? 0}'),
                            _buildTableCell(
                              '${((stats['excellent'] ?? 0) / (stats['total'] ?? 1) * 100).toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('Giỏi'),
                            _buildTableCell('${stats['verygood'] ?? 0}'),
                            _buildTableCell(
                              '${((stats['verygood'] ?? 0) / (stats['total'] ?? 1) * 100).toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('Khá'),
                            _buildTableCell('${stats['good'] ?? 0}'),
                            _buildTableCell(
                              '${((stats['good'] ?? 0) / (stats['total'] ?? 1) * 100).toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('Trung bình'),
                            _buildTableCell('${stats['average'] ?? 0}'),
                            _buildTableCell(
                              '${((stats['average'] ?? 0) / (stats['total'] ?? 1) * 100).toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = type;
          _selectedClass = null;
          _selectedDepartment = null;
          _tabController.animateTo(0);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _filterType == type
              ? Colors.blue.shade600
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _filterType == type ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String icon,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(color: color, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required int count,
    required Color color,
    required int total,
  }) {
    double percentage = total > 0 ? (count / total) * 100 : 0;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.2)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: count / (total > 0 ? total : 1),
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> stats) {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: (stats['excellent'] ?? 0).toDouble(),
              title: 'Xuất sắc\n${stats['excellent'] ?? 0}',
              color: Colors.green,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: (stats['verygood'] ?? 0).toDouble(),
              title: 'Giỏi\n${stats['verygood'] ?? 0}',
              color: Colors.blue,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: (stats['good'] ?? 0).toDouble(),
              title: 'Khá\n${stats['good'] ?? 0}',
              color: Colors.orange,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: (stats['average'] ?? 0).toDouble(),
              title: 'Trung bình\n${stats['average'] ?? 0}',
              color: Colors.red,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Xuất sắc', Colors.green, stats['excellent'] ?? 0),
          _buildLegendItem('Giỏi', Colors.blue, stats['verygood'] ?? 0),
          _buildLegendItem('Khá', Colors.orange, stats['good'] ?? 0),
          _buildLegendItem('Trung bình', Colors.red, stats['average'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.blue.shade700 : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<dynamic> students) {
    int excellent = students.where((s) => s.gpa >= 3.6).length;
    int verygood = students.where((s) => s.gpa >= 3.2 && s.gpa < 3.6).length;
    int good = students.where((s) => s.gpa >= 2.5 && s.gpa < 3.2).length;
    int average = students.where((s) => s.gpa < 2.5).length;

    return {
      'total': students.length,
      'excellent': excellent,
      'verygood': verygood,
      'good': good,
      'average': average,
    };
  }
}
