class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    return null;
  }

  static String? validateReviewContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Review content is required';
    }
    
    if (value.length < 10) {
      return 'Review must be at least 10 characters';
    }
    
    return null;
  }

  static String? validateDiscussionTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    
    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }
    
    return null;
  }
}