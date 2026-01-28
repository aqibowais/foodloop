/// Utility for validating Pakistani phone numbers
class PhoneValidator {
  /// Validates Pakistani phone number
  /// Accepts formats:
  /// - 03XX-XXXXXXX (with dash)
  /// - 03XXXXXXXXX (without dash)
  /// - +923XXXXXXXXX (with country code)
  /// - 00923XXXXXXXXX (with country code)
  static bool isValidPakistaniPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    
    // Remove all spaces, dashes, and parentheses
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Pattern for Pakistani mobile numbers
    // Starts with 03 or +92 or 0092, followed by 9 digits
    final pattern = RegExp(r'^(\+92|0092|0)?3\d{9}$');
    
    return pattern.hasMatch(cleaned);
  }
  
  /// Formats phone number for display
  /// Converts to format: 03XX-XXXXXXX
  static String? formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Remove country code if present
    String number = cleaned;
    if (cleaned.startsWith('+92')) {
      number = cleaned.substring(3);
    } else if (cleaned.startsWith('0092')) {
      number = cleaned.substring(4);
    }
    
    // Ensure it starts with 0
    if (!number.startsWith('0')) {
      number = '0$number';
    }
    
    // Format as 03XX-XXXXXXX
    if (number.length == 11) {
      return '${number.substring(0, 4)}-${number.substring(4)}';
    }
    
    return number;
  }
  
  /// Converts phone to tel: URL format
  /// Converts to +923XXXXXXXXX format
  static String? toTelUrl(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Remove leading 0 and add +92
    if (cleaned.startsWith('0')) {
      return '+92${cleaned.substring(1)}';
    } else if (cleaned.startsWith('+92')) {
      return cleaned;
    } else if (cleaned.startsWith('0092')) {
      return '+92${cleaned.substring(4)}';
    }
    
    return '+92$cleaned';
  }
}

