class AuthException implements Exception {
  final Map<String, String> errors = {
    'EMAIL_EXISTS': 'This email address is already in use.',
    'OPERATION_NOT_ALLOWED': 'Password sign-in is disabled for this project.',
    'TOO_MANY_ATTEMPTS_TRY_LATER':
        'We have blocked all requests from this device due to unusual activity. Try again later.',
    'EMAIL_NOT_FOUND': 'This email address is not registered.',
    'INVALID_PASSWORD': 'The password is invalid.',
    'USER_DISABLED': 'User has been disabled.',
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? 'An error occurred.';
  }
}