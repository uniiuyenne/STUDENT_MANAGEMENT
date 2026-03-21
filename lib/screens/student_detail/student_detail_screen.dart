import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../providers/student_provider.dart';
import '../../models/student.dart';
import '../../utils/animation_helper.dart';
import '../add_edit_student/add_edit_student_screen.dart';
import '../../widgets/common/tuition_detail_dialog.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${student.name} - Ảnh đại diện', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              student.avatarUrl.startsWith('http')
                  ? Image.network(student.avatarUrl, height: 200, width: 200, fit: BoxFit.cover)
                  : (student.avatarUrl.startsWith('data:')
                      ? Image.memory(base64Decode(student.avatarUrl.split(',')[1]), height: 200, width: 200, fit: BoxFit.cover)
                      : Image.file(File(student.avatarUrl), height: 200, width: 200, fit: BoxFit.cover)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sinh viên'), elevation: 2),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100.withOpacity(0.5),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Main Info Card
            Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: student.avatarUrl.isNotEmpty ? () => _showAvatarDialog(context) : null,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        backgroundImage: student.avatarUrl.isNotEmpty
                            ? NetworkImage(student.avatarUrl)
                            : null,
                        child: student.avatarUrl.isEmpty
                            ? Text(
                                student.name
                                    .split(' ')
                                    .map((e) => e.isNotEmpty ? e[0] : '')
                                    .take(2)
                                    .join()
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'MSV: ${student.studentId}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Basic Info
            _buildInfoSection(context, '📋 Thông tin cơ bản', [
              _buildInfoItem('Lớp', student.className, Icons.class_),
              _buildInfoItem('Khoa', student.department, Icons.apartment),
              _buildInfoItem(
                'Ngày sinh',
                student.dateOfBirth.toString().split(' ')[0],
                Icons.cake,
              ),
            ]),
            const SizedBox(height: 12),

            // Academic Info
            _buildInfoSection(context, '📚 Thông tin học tập', [
              _buildGpaCard(),
            ]),
            const SizedBox(height: 12),

            // Tuition Fee
            _buildTuitionSection(context),
            const SizedBox(height: 12),

            // Contact Info
            _buildInfoSection(context, '📞 Thông tin liên hệ', [
              _buildInfoItem('Email', student.email, Icons.email),
              _buildInfoItem('Số điện thoại', student.phone, Icons.phone),
            ]),
            const SizedBox(height: 12),

            // Subjects
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 Danh sách môn học',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (student.subjects.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Chưa có môn học nào'),
                      )
                    else
                      Column(
                        children: student.subjects
                            .map(
                              (subject) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(subject)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        AnimationHelper.createSlideTransition(
                          AddEditStudentScreen(student: student),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final provider = context.read<StudentProvider>();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text(
                            'Bạn có chắc muốn xóa sinh viên này?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await provider.deleteStudent(student.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xóa sinh viên thành công'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpaCard() {
    Color gpaColor = Colors.blueAccent;
    if (student.gpa < 2.5) {
      gpaColor = Colors.red;
    } else if (student.gpa < 3.2) {
      gpaColor = Colors.orange;
    } else if (student.gpa < 3.6) {
      gpaColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [gpaColor.withOpacity(0.8), gpaColor]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GPA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${student.gpa}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Xếp loại: ${student.status}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )} đ';
  }

  double _calculateTotalTuition() {
    const double creditsPerSubject = 2.0;
    const double creditPrice = 300000;
    int totalCredits = (student.subjects.length * creditsPerSubject).toInt();
    return totalCredits * creditPrice;
  }

  Widget _buildTuitionSection(BuildContext context) {
    double totalTuition = _calculateTotalTuition();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💰 Học phí',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng học phí',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(totalTuition),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: student.subjects.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => TuitionDetailDialog(
                                subjects: student.subjects,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                    ),
                    child: const Text('Chi tiết'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
