import 'package:equatable/equatable.dart';

/// User entity for domain layer
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user's email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  /// Get user's display name (fallback to email if name is empty)
  String get displayName => name.isNotEmpty ? name : email;

  /// Get user's initials for avatar
  String get initials {
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    profileImageUrl,
    emailVerifiedAt,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, isEmailVerified: $isEmailVerified)';
  }

  /// Create a copy with updated fields
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
