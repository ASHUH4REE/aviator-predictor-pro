/// Reusable form validators. All return `null` when the value is acceptable.
class Validators {
  Validators._();

  static String? required(String? v, {String label = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    final RegExp re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required.';
    final String digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Enter a valid phone number.';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v != original) return 'Passwords do not match.';
    return null;
  }
}
