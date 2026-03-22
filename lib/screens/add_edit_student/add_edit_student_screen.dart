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
    if (!kIsWeb) {
      final status = await Permission.photos.request();
      if (status.isDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập thư viện bị từ chối')),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
        _avatarUrl = '';
      });
    }
  }

  bool _studentIdExists(String studentId) {
    final provider = context.read<StudentProvider>();
    return provider.students.any((student) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ảnh đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(_imageBytes!, height: 300, width: 300, fit: BoxFit.cover),
                )
              else if (_avatarUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_avatarUrl, height: 300, width: 300, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
          ),
          child: child!,
        );
      },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: AppConstants.classes
                      .map((cls) => ListTile(
                            title: Text(cls),
                            selected: _classController.text == cls,
                            selectedTileColor: Colors.blue.shade50,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: AppConstants.departments
                      .map((dept) => ListTile(
                            title: Text(dept),
                            selected: _departmentController.text == dept,
                            selectedTileColor: Colors.blue.shade50,
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
      if (_dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
        );
        return;
      }

      final provider = context.read<StudentProvider>();
      final messenger = ScaffoldMessenger.of(context);

      String avatarUrl = _avatarUrl;
      if (_selectedImage != null) {
        messenger.showSnackBar(const SnackBar(content: Text('Đang tải ảnh lên...')));
        final uploadedUrl = await provider.uploadAvatar(
          _selectedImage!,
          _studentIdController.text.isNotEmpty ? _studentIdController.text : 'temp',
        );
        if (uploadedUrl != null) {
          avatarUrl = uploadedUrl;
        } else {
          messenger.showSnackBar(const SnackBar(content: Text('Lỗi tải ảnh lên')));
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
          messenger.showSnackBar(const SnackBar(content: Text('Thêm sinh viên thành công')));
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          await provider.updateStudent(student);
          if (!mounted) return;
          messenger.showSnackBar(const SnackBar(content: Text('Cập nhật sinh viên thành công')));
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
        title: Text(widget.student == null ? 'Thêm sinh viên' : 'Chỉnh sửa sinh viên'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade50],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildSectionHeader(context, '📋 Thông tin cơ bản'),
                const SizedBox(height: 16),
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
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: _imageBytes != null
                                    ? MemoryImage(_imageBytes!)
                                    : (_avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null),
                                child: _imageBytes == null && _avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 55, color: Colors.blue)
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade800,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn để xem ảnh chi tiết',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(_nameController, 'Tên sinh viên', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(_studentIdController, 'Mã sinh viên', Icons.badge, validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập mã sinh viên';
                  if (_studentIdExists(value)) return 'Mã sinh viên đã tồn tại';
                  return null;
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerField(_classController, 'Lớp', Icons.class_, () => _showClassPicker(context)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPickerField(_departmentController, 'Khoa', Icons.apartment, () => _showDepartmentPicker(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, '📚 Thông tin học tập'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_gpaController, 'GPA', Icons.grade, isNumber: true, validator: (value) {
                        if (value!.isEmpty) return 'Vui lòng nhập GPA';
                        final gpa = double.tryParse(value);
                        if (gpa == null || gpa < 0 || gpa > 4) return 'GPA: 0-4';
                        return null;
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(' Ngày sinh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          OutlinedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(_dateOfBirth == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(_dateOfBirth!)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.list_alt, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text('Môn học đã chọn', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('${_selectedSubjects.length}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Wrap(
                          spacing: 6,
                          runSpacing: 0,
                          children: AppConstants.subjects.map((subject) {
                            final isSelected = _selectedSubjects.contains(subject);
                            return FilterChip(
                              label: Text(subject, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selected ? _selectedSubjects.add(subject) : _selectedSubjects.remove(subject);
                                });
                              },
                              selectedColor: Colors.blue.shade600,
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, '📞 Thông tin liên hệ'),
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
                const SizedBox(height: 12),
                _buildTextField(_phoneController, 'Số điện thoại', Icons.phone, isPhone: true),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveStudent(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text('Lưu thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isEmail = false, bool isPhone = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return 'Không được để trống';
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Email không hợp lệ';
        return null;
      },
    );
  }

  Widget _buildPickerField(TextEditingController controller, String label, IconData icon, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Chọn $label' : null,
    );
  }
}
