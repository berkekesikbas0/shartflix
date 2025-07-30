import 'package:equatable/equatable.dart';

/// Authentication token entity for domain layer
class AuthTokenEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;
  final List<String> scopes;

  const AuthTokenEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
    this.scopes = const [],
  });

  /// Calculate expiration date
  DateTime get expiresAt => issuedAt.add(Duration(seconds: expiresIn));

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token will expire soon (within 5 minutes)
  bool get willExpireSoon {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// Get remaining time until expiration
  Duration get remainingTime {
    final now = DateTime.now();
    return expiresAt.isAfter(now) ? expiresAt.difference(now) : Duration.zero;
  }

  /// Format token for Authorization header
  String get authorizationHeader => '$tokenType $accessToken';

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
    issuedAt,
    scopes,
  ];

  @override
  String toString() {
    return 'AuthTokenEntity(tokenType: $tokenType, expiresAt: $expiresAt, isExpired: $isExpired)';
  }

  /// Create a copy with updated fields
  AuthTokenEntity copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    List<String>? scopes,
  }) {
    return AuthTokenEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      scopes: scopes ?? this.scopes,
    );
  }
}
