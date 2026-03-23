import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/student.dart';
import '../services/supabase_service.dart';

class StudentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseService _supabaseService = SupabaseService();
  static const String _localStudentsKey = 'students_local_cache_v1';
  List<Student> _students = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;

  Future<void> _saveStudentsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _students
          .map((student) => {
                'id': student.id,
                ...student.toMap(),
              })
          .toList();
      await prefs.setString(_localStudentsKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving local students: $e');
    }
  }

  Future<List<Student>> _loadStudentsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localStudentsKey);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            final id = map['id']?.toString() ??
                'local_${DateTime.now().microsecondsSinceEpoch}';
            map.remove('id');
            return Student.fromMap(id, map);
          })
          .toList()
        ..sort((a, b) {
          final timeA = a.createdAt ?? DateTime(1970);
          final timeB = b.createdAt ?? DateTime(1970);
          return timeB.compareTo(timeA);
        });
    } catch (e) {
      debugPrint('Error loading local students: $e');
      return [];
    }
  }

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

      await _saveStudentsToLocal();
    } catch (e) {
      debugPrint('Error fetching students from Firestore: $e');
      _students = await _loadStudentsFromLocal();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Add student
  Future<bool> addStudent(Student student) async {
    try {
      try {
        DocumentReference docRef = await _firestore
            .collection('students')
            .add(student.toMap());
        student.id = docRef.id;
      } catch (e) {
        debugPrint('Add to Firestore failed, fallback to local: $e');
        if (student.id.isEmpty) {
          student.id = 'local_${DateTime.now().microsecondsSinceEpoch}';
        }
      }

      _students.insert(0, student);
      await _saveStudentsToLocal();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding student: $e');
      return false;
    }
  }

  // Update student
  Future<bool> updateStudent(Student student) async {
    try {
      try {
        await _firestore
            .collection('students')
            .doc(student.id)
            .update(student.toMap());
      } catch (e) {
        debugPrint('Update Firestore failed, fallback to local: $e');
      }

      int index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
        await _saveStudentsToLocal();
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error updating student: $e');
      return false;
    }
  }

  // Delete student
  Future<bool> deleteStudent(String id) async {
    try {
      final studentToDelete = _students.cast<Student?>().firstWhere(
            (s) => s?.id == id,
            orElse: () => null,
          );

      final avatarUrl = studentToDelete?.avatarUrl ?? '';
      if (avatarUrl.isNotEmpty) {
        try {
          await _supabaseService.deleteAvatar(avatarUrl);
        } catch (e) {
          debugPrint('Delete avatar on Supabase failed: $e');
        }
      }

      try {
        await _firestore.collection('students').doc(id).delete();
      } catch (e) {
        debugPrint('Delete Firestore failed, fallback to local: $e');
      }

      _students.removeWhere((s) => s.id == id);
      await _saveStudentsToLocal();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting student: $e');
      return false;
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
