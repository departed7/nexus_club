class Validators {
  static String? required(String? value, [String message = 'Поле обязательно для заполнения']) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? minLength(String? value, int min, [String? message]) {
    if (value == null || value.trim().length < min) {
      return message ?? 'Минимальная длина — $min символов';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String? message]) {
    if (value != null && value.trim().length > max) {
      return message ?? 'Максимальная длина — $max символов';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String message = 'Введите положительное число']) {
    if (value == null || value.trim().isEmpty) return 'Поле обязательно';
    final parsed = double.tryParse(value.replaceAll(',', '.').trim());
    if (parsed == null || parsed <= 0) return message;
    return null;
  }

  static String? numberRange(String? value, double min, double max, [String? message]) {
    if (value == null || value.trim().isEmpty) return 'Поле обязательно';
    final parsed = double.tryParse(value.replaceAll(',', '.').trim());
    if (parsed == null || parsed < min || parsed > max) {
      return message ?? 'Значение должно быть в диапазоне от $min до $max';
    }
    return null;
  }

  static String? email(String? value, [String message = 'Некорректный адрес электронной почты']) {
    if (value == null || value.trim().isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return message;
    return null;
  }

  static String? ipAddress(String? value, [String message = 'Некорректный IP-адрес (формат: 192.168.1.X)']) {
    if (value == null || value.trim().isEmpty) return 'Введите IP-адрес';
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(value.trim())) return message;
    return null;
  }
}