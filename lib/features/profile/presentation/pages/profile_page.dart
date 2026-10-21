import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource();
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final p = await _dataSource.getProfile();
      if (mounted && p != null) {
        setState(() {
          _profile = p;
          _fullNameController.text = p.fullName ?? '';
          _phoneController.text = p.phone ?? '';
          _addressController.text = p.address ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải thông tin hồ sơ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage({required bool isAvatar}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        // Không truyền imageQuality để bảo toàn nguyên vẹn tất cả frames của ảnh GIF
      );

      if (pickedFile == null) return;

      setState(() {
        if (isAvatar) {
          _isUploadingAvatar = true;
        } else {
          _isUploadingCover = true;
        }
      });

      final String folder = isAvatar ? 'avatars' : 'covers';
      final String publicUrl = await _dataSource.uploadImage(
        file: pickedFile,
        folder: folder,
      );

      if (mounted) {
        final currentProfile = _profile ??
            await _dataSource.getProfile() ??
            ProfileModel(
              id: _dataSource.currentUserId ?? '',
              email: _dataSource.currentUserEmail,
              fullName: _fullNameController.text.trim(),
            );

        final updatedProfile = isAvatar
            ? currentProfile.copyWith(avatarUrl: publicUrl)
            : currentProfile.copyWith(coverUrl: publicUrl);

        await _dataSource.updateProfile(updatedProfile);

        if (mounted) {
          setState(() {
            _profile = updatedProfile;
            if (isAvatar) {
              _isUploadingAvatar = false;
            } else {
              _isUploadingCover = false;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAvatar ? '✅ Đã cập nhật ảnh đại diện!' : '✅ Đã cập nhật ảnh bìa!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (isAvatar) {
            _isUploadingAvatar = false;
          } else {
            _isUploadingCover = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tải ảnh thất bại: $e. Hãy kiểm tra bucket "Images" trên Supabase!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _profile == null) return;

    setState(() => _isSaving = true);
    try {
      final updatedProfile = _profile!.copyWith(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      await _dataSource.updateProfile(updatedProfile);

      if (mounted) {
        setState(() {
          _profile = updatedProfile;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã lưu thay đổi thông tin cá nhân!'),
            backgroundColor: Colors.deepPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu thất bại: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _profile?.avatarUrl;
    final coverUrl = _profile?.coverUrl;
    final email = _profile?.email ?? _dataSource.currentUserEmail ?? 'Chưa cập nhật';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Khối Ảnh bìa + Avatar (Có kích thước 242 để HitTest nhận toàn bộ vùng nhấn của Avatar)
                  SizedBox(
                    height: 242,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Ảnh bìa (Cover Image)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 190,
                          child: FadeIn(
                            duration: const Duration(milliseconds: 400),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                              child: Container(
                                height: 190,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (coverUrl != null && coverUrl.isNotEmpty)
                                      Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 190,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(Icons.broken_image, color: Colors.white70, size: 36),
                                            ),
                                          );
                                        },
                                      ),
                                    if (_isUploadingCover)
                                      Container(
                                        color: Colors.black38,
                                        child: const Center(
                                          child: CircularProgressIndicator(color: Colors.white),
                                        ),
                                      ),
                                    Positioned(
                                      right: 14,
                                      bottom: 14,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _pickAndUploadImage(isAvatar: false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                              SizedBox(width: 6),
                                              Text(
                                                'Đổi ảnh bìa',
                                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 2. Avatar tròn (hỗ trợ GIF chuyển động mượt mà & nhận cảm ứng nhạy bén)
                        Positioned(
                          top: 138, // 190 - 52 = 138 -> nằm cân đối ngay mép dưới ảnh bìa
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 450),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    onTap: () => _pickAndUploadImage(isAvatar: true),
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      width: 104,
                                      height: 104,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.deepPurple.shade50,
                                        border: Border.all(color: Colors.white, width: 4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: avatarUrl != null && avatarUrl.isNotEmpty
                                            ? Image.network(
                                                avatarUrl,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.person,
                                                    size: 54,
                                                    color: Colors.deepPurple,
                                                  );
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return const Center(
                                                    child: SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    ),
                                                  );
                                                },
                                              )
                                            : const Icon(
                                                Icons.person,
                                                size: 54,
                                                color: Colors.deepPurple,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isUploadingAvatar)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black38,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _pickAndUploadImage(isAvatar: true),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tên hiển thị & Email nhanh
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        Text(
                          _fullNameController.text.isNotEmpty ? _fullNameController.text : 'Người dùng',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form chi tiết thông tin
                  FadeInUp(
                    duration: const Duration(milliseconds: 550),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin cá nhân',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                            ),
                            const SizedBox(height: 16),

                            // Họ và tên
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Họ và tên',
                                hintText: 'Nhập họ và tên...',
                                prefixIcon: const Icon(Icons.badge_outlined, color: Colors.deepPurple),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập họ và tên';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email (Khóa không sửa, chính là account)
                            TextFormField(
                              initialValue: email,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Email tài khoản (Không thể sửa)',
                                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                                suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Số điện thoại
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Số điện thoại',
                                hintText: 'Ví dụ: 0912345678',
                                prefixIcon: const Icon(Icons.phone_outlined, color: Colors.deepPurple),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Địa chỉ
                            TextFormField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Địa chỉ',
                                hintText: 'Nhập địa chỉ của bạn...',
                                prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.deepPurple),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Nút Lưu
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 3,
                                ),
                                onPressed: _isSaving ? null : _saveProfile,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: Text(
                                  _isSaving ? 'Đang lưu...' : 'LƯU THAY ĐỔI',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
