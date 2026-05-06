class AppValidators {
  static String? requiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredText(value, 'Email');
    if (requiredError != null) return requiredError;

    if (!value!.contains('@')) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredText(value, 'Password');
    if (requiredError != null) return requiredError;

    if (value!.length < 6) {
      return 'Minimum 6 characters required';
    }

    return null;
  }

  static String? issueTitle(String? value) {
    return requiredText(value, 'Title');
  }

  static String? issueDescription(String? value) {
    return requiredText(value, 'Description');
  }
}
