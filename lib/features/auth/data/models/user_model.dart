class UserModel {
  final int id;
  final String email;
  final String fullName;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
    };
  }
}

class TokenModel {
  final String accessToken;
  final String tokenType;

  TokenModel({
    required this.accessToken,
    required this.tokenType,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}
