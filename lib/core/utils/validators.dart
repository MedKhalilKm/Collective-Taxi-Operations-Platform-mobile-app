class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    final usernameTrimmed = value.trim();
    if (usernameTrimmed.length < 2 || usernameTrimmed.length > 30) {
      return 'Username must be between 2 and 30 characters';
    }
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_.-]+$');
    if (!usernameRegExp.hasMatch(usernameTrimmed)) {
      return 'Username can only contain letters, numbers, dots, hyphens, and underscores';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneTrimmed = value.trim();
    if (phoneTrimmed.length < 6) {
      return 'Phone number must be at least 6 characters';
    }
    final phoneRegExp = RegExp(r'^[+0-9\s-]+$');
    if (!phoneRegExp.hasMatch(phoneTrimmed)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value.length > 128) {
      return 'Password must not exceed 128 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateSignInIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or username is required';
    }
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      return validateEmail(trimmed);
    } else {
      if (trimmed.length < 2) {
        return 'Username must be at least 2 characters';
      }
    }
    return null;
  }
}
