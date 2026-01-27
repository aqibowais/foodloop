/// App-wide constants
class AppConstants {
  // Free tier limits
  static const int freeVideoLimit = 5;

  // Video constraints
  static const int maxVideoSizeMB = 100;
  static const int minVideoSizeKB = 1;
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
  ];

  // Supported platforms for URL extraction
  static const List<String> supportedPlatforms = [
    'instagram.com',
    'tiktok.com',
    'facebook.com',
  ];

  // API endpoints (to be configured)
  static const String truthScanBaseUrl = 'https://detect-video.truthscan.com';
  static const String truthScanDetectEndpoint = '/detect-file';
  static const String truthScanQueryEndpoint = '/query';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String historyCollection = 'history';

  // Storage paths
  static const String frameImagesPath = 'frame_images';
}
