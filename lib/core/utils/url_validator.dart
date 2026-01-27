import 'constants.dart';

/// Utility class for URL validation and parsing
class UrlValidator {
  /// Check if URL is from a supported platform
  static bool isSupportedPlatform(String url) {
    final lowerUrl = url.toLowerCase();
    return AppConstants.supportedPlatforms.any(
      (platform) => lowerUrl.contains(platform),
    );
  }

  /// Extract platform name from URL
  static String? getPlatform(String url) {
    final lowerUrl = url.toLowerCase();
    for (final platform in AppConstants.supportedPlatforms) {
      if (lowerUrl.contains(platform)) {
        return platform.split('.').first; // instagram, tiktok, facebook
      }
    }
    return null;
  }

  /// Validate if URL is valid
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

