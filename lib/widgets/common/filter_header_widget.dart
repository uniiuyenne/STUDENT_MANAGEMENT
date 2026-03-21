import 'package:flutter/material.dart';

class FilterHeaderWidget extends StatelessWidget {
  final String classFilter;
  final String deptFilter;
  final double? gpaFilter;
  final int studentCount;
  final VoidCallback onFilterTap;

  const FilterHeaderWidget({
    super.key,
    required this.classFilter,
    required this.deptFilter,
    required this.gpaFilter,
    required this.studentCount,
    required this.onFilterTap,
  });

  bool get _hasActiveFilters =>
      classFilter.isNotEmpty || deptFilter.isNotEmpty || gpaFilter != null;

  String _buildFilterDisplay() {
    if (!_hasActiveFilters) {
      return 'Danh sách sinh viên';
    }

    List<String> filters = [];
    if (classFilter.isNotEmpty) {
      filters.add('Lớp: $classFilter');
    }
    if (deptFilter.isNotEmpty) {
      filters.add('Khoa: $deptFilter');
    }
    if (gpaFilter != null) {
      filters.add('GPA: ${gpaFilter?.toStringAsFixed(2)}');
    }

    return filters.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Danh sách sinh viên',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _hasActiveFilters ? Colors.purple[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 18,
                        color: _hasActiveFilters ? Colors.purple[600] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Quản lý',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _hasActiveFilters ? Colors.purple[600] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 8),
            Text(
              _buildFilterDisplay(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Tổng: $studentCount sinh viên',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
