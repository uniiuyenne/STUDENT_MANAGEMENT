class Student {
  String id;
  String name;
  String studentId;
  String className;
  String department;
  DateTime dateOfBirth;
  double gpa;
  String email;
  String phone;
  String avatarUrl;
  List<String> subjects; // List of subjects
  DateTime? createdAt; // Timestamp khi tạo

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.className,
    required this.department,
    required this.dateOfBirth,
    required this.gpa,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.subjects,
    this.createdAt,
  });

  // From Firestore
  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      studentId: data['studentId'] ?? '',
      className: data['className'] ?? '',
      department: data['department'] ?? '',
      dateOfBirth: DateTime.parse(data['dateOfBirth']),
      gpa: data['gpa']?.toDouble() ?? 0.0,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      subjects: List<String>.from(data['subjects'] ?? []),
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'])
          : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studentId': studentId,
      'className': className,
      'department': department,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gpa': gpa,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'subjects': subjects,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Status based on GPA
  String get status {
    if (gpa >= 3.6) return 'Xuất sắc';
    if (gpa >= 3.2) return 'Giỏi';
    if (gpa >= 2.5) return 'Khá';
    return 'Trung bình';
  }
}
