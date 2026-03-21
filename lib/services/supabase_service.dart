import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sanitize file name to remove special characters
  String _sanitizeFileName(String input) {
    return input
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_') // Replace non-alphanumeric with underscore
        .replaceAll(RegExp(r'_+'), '_') // Collapse multiple underscores
        .toLowerCase();
  }

  // Upload avatar image to Supabase Storage
  Future<String?> uploadAvatar(XFile imageFile, String studentId) async {
    try {
      // Sanitize student ID to remove special characters
      final sanitizedId = _sanitizeFileName(studentId);
      final fileName = '${sanitizedId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Read file as bytes (works on both mobile/desktop and web)
      final fileBytes = await imageFile.readAsBytes();

      // Upload file to Supabase Storage
      final response = await _supabase.storage
          .from(avatarBucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      if (response.isNotEmpty) {
        // Get public URL
        final publicUrl = _supabase.storage
            .from(avatarBucket)
            .getPublicUrl(fileName);

        return publicUrl;
      }
    } catch (e) {
      // print('Error uploading avatar: $e');
    }
    return null;
  }

  // Delete avatar from Supabase Storage
  Future<bool> deleteAvatar(String avatarUrl) async {
    try {
      // Extract file name from URL
      final uri = Uri.parse(avatarUrl);
      final fileName = uri.pathSegments.last;

      await _supabase.storage
          .from(avatarBucket)
          .remove([fileName]);

      return true;
    } catch (e) {
      // print('Error deleting avatar: $e');
      return false;
    }
  }
}