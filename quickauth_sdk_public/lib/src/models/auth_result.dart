class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: (json['success'] as bool?) ?? false,
      message: (json['message'] as String?) ?? 'Unknown response',
      token: json['token'] as String?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'token': token,
      'user': user,
    };
  }
}
