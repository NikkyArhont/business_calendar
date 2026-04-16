class AppError implements Exception {
  final String message;
  final String? code;

  AppError(this.message, {this.code});

  @override
  String toString() => 'AppError: $message (code: $code)';
}
