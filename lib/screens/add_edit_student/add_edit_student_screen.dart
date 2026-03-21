import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../../providers/student_provider.dart';
import '../../models/student.dart';
import '../../constants/app_constants.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _classController;
  late TextEditingController _departmentController;
  late TextEditingController _gpaController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _avatarController;
  
  List<String> _selectedSubjects = [];
  
  DateTime? _dateOfBirth;
  String _avatarUrl = '';
  XFile? _selectedImage;
  Uint8List? _imageBytes;  // For web support

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _studentIdController = TextEditingController(
      text: widget.student?.studentId ?? '',
    );
    _classController = TextEditingController(
      text: widget.student?.className ?? '',
    );
    _departmentController = TextEditingController(
      text: widget.student?.department ?? '',
    );
    _gpaController = TextEditingController(
      text: widget.student?.gpa.toString() ?? '',
    );
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _avatarController = TextEditingController(
      text: widget.student?.avatarUrl ?? '',
    );
    
    _selectedSubjects = widget.student?.subjects ?? [];
    _dateOfBirth = widget.student?.dateOfBirth;
    _avatarUrl = widget.student?.avatarUrl ?? '';

    _nameController.addListener(() => setState(() {}));
    _avatarController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _classController.dispose();
    _departmentController.dispose();
    _gpaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Request permission only on mobile platforms
    if (!kIsWeb) {
      final status = await Permission.photos.request();
      
      if (status.isDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập thư viện bị từ chối')),
        );
        return;
      }
      
      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cấp quyền trong cài đặt ứng dụng')),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Load bytes for web compatibility
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
        _avatarUrl = ''; // Clear URL when new image is selected
      });
    }
  }

  // Check if student ID already exists
  bool _studentIdExists(String studentId) {
    final provider = context.read<StudentProvider>();
    return provider.students.any((student) {
      // If editing, exclude current student
      if (widget.student != null && student.id == widget.student!.id) {
        return false;
      }
      return student.studentId == studentId;
    });
  }

  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ảnh đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_imageBytes != null)
                Image.memory(_imageBytes!, height: 300, width: 300, fit: BoxFit.cover)
              else if (_avatarUrl.isNotEmpty)
                Image.network(_avatarUrl, height: 300, width: 300, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  width: 300,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image),
                ))
              else
                Container(
                  height: 300,
                  width: 300,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _showClassPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn Lớp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) {
                  // Filter logic if needed
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: AppConstants.classes
                      .map((cls) => ListTile(
                            title: Text(cls),
                            selected: _classController.text == cls,
                            selectedTileColor: Colors.blue.shade100,
                            onTap: () {
                              setState(() {
                                _classController.text = cls;
                              });
                              Navigator.pop(context);
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepartmentPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn Khoa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) {
                  // Filter logic if needed
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: AppConstants.departments
                      .map((dept) => ListTile(
                            title: Text(dept),
                            selected: _departmentController.text == dept,
                            selectedTileColor: Colors.blue.shade100,
                            onTap: () {
                              setState(() {
                                _departmentController.text = dept;
                              });
                              Navigator.pop(context);
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<StudentProvider>();
      final messenger = ScaffoldMessenger.of(context);

      // Upload avatar if selected
      String avatarUrl = _avatarUrl;
      if (_selectedImage != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Đang tải ảnh lên...')),
        );

        final uploadedUrl = await provider.uploadAvatar(
          _selectedImage!,
          _studentIdController.text.isNotEmpty ? _studentIdController.text : 'temp',
        );

        if (uploadedUrl != null) {
          avatarUrl = uploadedUrl;
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('Lỗi tải ảnh lên')),
          );
          return;
        }
      }

      final student = Student(
        id: widget.student?.id ?? '',
        name: _nameController.text,
        studentId: _studentIdController.text,
        className: _classController.text,
        department: _departmentController.text,
        dateOfBirth: _dateOfBirth!,
        gpa: double.parse(_gpaController.text),
        email: _emailController.text,
        phone: _phoneController.text,
        avatarUrl: avatarUrl,
        subjects: _selectedSubjects,
      );

      try {
        if (widget.student == null) {
          await provider.addStudent(student);
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(content: Text('Thêm sinh viên thành công')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          await provider.updateStudent(student);
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(content: Text('Cập nhật sinh viên thành công')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.student == null ? 'Thêm sinh viên' : 'Chỉnh sửa sinh viên',
        ),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Basic Information Section
                _buildSectionHeader(context, '📋 Thông tin cơ bản'),
                const SizedBox(height: 12),

                // Avatar Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: (_selectedImage != null || _avatarUrl.isNotEmpty)
                                ? () => _showAvatarDialog(context)
                                : null,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue.shade200,
                              backgroundImage: _imageBytes != null
                                  ? MemoryImage(_imageBytes!)
                                  : (_avatarUrl.isNotEmpty
                                      ? NetworkImage(_avatarUrl)
                                      : null),
                              child: _imageBytes == null && _avatarUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade600,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ảnh đại diện (nhấn để xem chi tiết)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên sinh viên',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: 'Mã sinh viên',
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Vui lòng nhập mã sinh viên';
                    }
                    if (_studentIdExists(value)) {
                      return 'Mã sinh viên này đã tồn tại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _classController,
                        decoration: InputDecoration(
                          labelText: 'Lớp',
                          prefixIcon: const Icon(Icons.class_),
                          hintText: 'Nhập hoặc chọn',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () => _showClassPicker(context),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) =>
                            value!.isEmpty ? 'Vui lòng nhập lớp' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _departmentController,
                        decoration: InputDecoration(
                          labelText: 'Khoa',
                          prefixIcon: const Icon(Icons.apartment),
                          hintText: 'Nhập hoặc chọn',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () => _showDepartmentPicker(context),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) =>
                            value!.isEmpty ? 'Vui lòng nhập khoa' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Academic Information Section
                _buildSectionHeader(context, '📚 Thông tin học tập'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gpaController,
                        decoration: InputDecoration(
                          labelText: 'GPA',
                          prefixIcon: const Icon(Icons.grade),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return 'Vui lòng nhập GPA';
                          final gpa = double.tryParse(value);
                          if (gpa == null || gpa < 0 || gpa > 4) {
                            return 'GPA: 0-4';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _dateOfBirth == null
                                  ? 'Chọn ngày sinh'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_dateOfBirth!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Ngày'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Subjects multi-select
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.list, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'Danh sách môn học',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            if (_selectedSubjects.isNotEmpty)
                              Chip(
                                label: Text('${_selectedSubjects.length}'),
                                backgroundColor: Colors.blue.shade200,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: AppConstants.subjects.map((subject) {
                            final isSelected = _selectedSubjects.contains(subject);
                            return FilterChip(
                              label: Text(subject),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedSubjects.add(subject);
                                  } else {
                                    _selectedSubjects.remove(subject);
                                  }
                                });
                              },
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: Colors.blue.shade200,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contact Information Section
                _buildSectionHeader(context, '📞 Thông tin liên hệ'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Vui lòng nhập email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                ),
                const SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _saveStudent(),
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
