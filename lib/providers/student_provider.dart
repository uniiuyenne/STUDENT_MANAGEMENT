import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/student.dart';
import '../services/supabase_service.dart';

class StudentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseService _supabaseService = SupabaseService();
  List<Student> _students = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;

  // Fetch students from Firestore
  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore.collection('students').get();
      _students = snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      // Sort by createdAt descending (mới nhất trước) - client side
      _students.sort((a, b) {
        final timeA = a.createdAt ?? DateTime(1970);
        final timeB = b.createdAt ?? DateTime(1970);
        return timeB.compareTo(timeA); // Descending
      });
    } catch (e) {
      // print('Error fetching students: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Add student
  Future<void> addStudent(Student student) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('students')
          .add(student.toMap());
      student.id = docRef.id;
      _students.insert(0, student);
      notifyListeners();
    } catch (e) {
      // print('Error adding student: $e');
    }
  }

  // Update student
  Future<void> updateStudent(Student student) async {
    try {
      await _firestore
          .collection('students')
          .doc(student.id)
          .update(student.toMap());
      int index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
        notifyListeners();
      }
    } catch (e) {
      // print('Error updating student: $e');
    }
  }

  // Delete student
  Future<void> deleteStudent(String id) async {
    try {
      await _firestore.collection('students').doc(id).delete();
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      // print('Error deleting student: $e');
    }
  }

  // Upload avatar to Supabase
  Future<String?> uploadAvatar(XFile imageFile, String studentId) async {
    return await _supabaseService.uploadAvatar(imageFile, studentId);
  }

  // Delete avatar from Supabase
  Future<bool> deleteAvatar(String avatarUrl) async {
    return await _supabaseService.deleteAvatar(avatarUrl);
  }

  // Search and filter
  List<Student> getFilteredStudents(
    String query,
    String classFilter,
    String deptFilter,
    double? gpaMin,
  ) {
    final lowerQuery = query.toLowerCase();
    final lowerClass = classFilter.toLowerCase();
    final lowerDept = deptFilter.toLowerCase();

    return _students.where((student) {
      final name = student.name.toLowerCase();
      final id = student.studentId.toLowerCase();
      final studentClass = student.className.toLowerCase();
      final department = student.department.toLowerCase();

      bool matchesQuery =
          query.isEmpty || name.contains(lowerQuery) || id.contains(lowerQuery);
      bool matchesClass =
          classFilter.isEmpty || studentClass.contains(lowerClass);
      bool matchesDept = deptFilter.isEmpty || department.contains(lowerDept);
      bool matchesGpa = gpaMin == null || student.gpa >= gpaMin;
      return matchesQuery && matchesClass && matchesDept && matchesGpa;
    }).toList();
  }

  // Statistics
  Map<String, int> getStatistics() {
    int total = _students.length;
    int excellent = _students.where((s) => s.gpa >= 3.6).length;
    int verygood = _students.where((s) => s.gpa >= 3.2 && s.gpa < 3.6).length;
    int good = _students.where((s) => s.gpa >= 2.5 && s.gpa < 3.2).length;
    int average = _students.where((s) => s.gpa < 2.5).length;
    return {
      'total': total,
      'excellent': excellent,
      'verygood': verygood,
      'good': good,
      'average': average,
    };
  }
}
