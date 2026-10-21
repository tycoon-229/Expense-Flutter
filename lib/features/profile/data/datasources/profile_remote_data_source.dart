import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  /// Lấy thông tin hồ sơ của user
  Future<ProfileModel?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return ProfileModel.fromJson(response);
      } else {
        // Nếu chưa có (người dùng cũ trước khi tạo trigger), tự động tạo bản ghi ban đầu
        final newProfile = ProfileModel(
          id: userId,
          email: currentUserEmail,
          fullName: _supabase.auth.currentUser?.userMetadata?['full_name'] as String? ?? '',
        );
        await _supabase.from('profiles').upsert(newProfile.toJson());
        return newProfile;
      }
    } catch (e) {
      debugPrint('Lỗi tải profile từ Supabase: $e');
      rethrow;
    }
  }

  /// Cập nhật thông tin profile
  Future<void> updateProfile(ProfileModel profile) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    try {
      await _supabase
          .from('profiles')
          .upsert(profile.toJson());
    } catch (e) {
      debugPrint('Lỗi cập nhật profile: $e');
      rethrow;
    }
  }

  /// Tải ảnh (Avatar hoặc Ảnh bìa, hỗ trợ PNG, JPG, GIF...) lên Storage Bucket 'Images' (hoặc fallback 'images')
  Future<String> uploadImage({
    required XFile file,
    required String folder, // 'avatars' hoặc 'covers'
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    try {
      final Uint8List fileBytes = await file.readAsBytes();
      final String fileName = file.name;
      String fileExt = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'jpg';

      // Tự động nhận diện header byte để bảo toàn định dạng GIF / PNG
      if (fileBytes.length >= 3 && fileBytes[0] == 0x47 && fileBytes[1] == 0x49 && fileBytes[2] == 0x46) {
        fileExt = 'gif';
      } else if (fileBytes.length >= 4 && fileBytes[0] == 0x89 && fileBytes[1] == 0x50 && fileBytes[2] == 0x4E && fileBytes[3] == 0x47) {
        fileExt = 'png';
      }

      final String path = '$folder/${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      String contentType = 'image/jpeg';
      if (fileExt == 'gif') {
        contentType = 'image/gif';
      } else if (fileExt == 'png') {
        contentType = 'image/png';
      } else if (fileExt == 'webp') {
        contentType = 'image/webp';
      }

      // Thử tải lên bucket 'Images' trước; nếu bucket trên Supabase là chữ thường 'images', thử tiếp fallback
      String targetBucket = 'Images';
      try {
        await _supabase.storage.from(targetBucket).uploadBinary(
              path,
              fileBytes,
              fileOptions: FileOptions(
                contentType: contentType,
                upsert: true,
              ),
            );
      } catch (uploadError) {
        final errStr = uploadError.toString().toLowerCase();
        if (errStr.contains('bucket not found') || errStr.contains('not found')) {
          targetBucket = 'images';
          await _supabase.storage.from(targetBucket).uploadBinary(
                path,
                fileBytes,
                fileOptions: FileOptions(
                  contentType: contentType,
                  upsert: true,
                ),
              );
        } else {
          rethrow;
        }
      }

      final String publicUrl = _supabase.storage.from(targetBucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Lỗi upload ảnh lên bucket Images: $e');
      rethrow;
    }
  }
}
