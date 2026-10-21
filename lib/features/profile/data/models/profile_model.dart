class ProfileModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final String? coverUrl;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.address,
    this.avatarUrl,
    this.coverUrl,
    this.updatedAt,
  });

  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? avatarUrl,
    String? coverUrl,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
