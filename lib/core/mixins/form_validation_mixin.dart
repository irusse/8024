mixin FormValidationMixin {
  /// Валидация имени (обязательное, минимум 3 символа)
  ///
  /// Возвращает:
  /// - `null` если валидация прошла успешно
  /// - Сообщение об ошибке если валидация не прошла
  String? validateName(String firstName) {
    if (firstName.trim().isEmpty) {
      return 'Имя обязательно для заполнения';
    }
    if (firstName.trim().length < 3) {
      return 'Имя должно содержать минимум 3 символа';
    }
    return null;
  }

  /// Валидация фамилии (может быть пустой, но если заполнена - минимум 3 символа)
  ///
  /// Возвращает:
  /// - `null` если валидация прошла успешно или поле пустое
  /// - Сообщение об ошибке если валидация не прошла
  String? validateLastName(String? lastName) {
    if (lastName == null || lastName.trim().isEmpty) {
      return null; // Фамилия может быть пустой
    }
    if (lastName.trim().length < 3) {
      return 'Фамилия должна содержать минимум 3 символа';
    }
    return null;
  }

  /// Валидация email (может быть пустым, но если заполнен - должен быть корректным)
  ///
  /// Возвращает:
  /// - `null` если валидация прошла успешно или поле пустое
  /// - Сообщение об ошибке если валидация не прошла
  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return null; // Email может быть пустым
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Введите корректный email адрес';
    }
    return null;
  }

} 