/// Cloudinary configuration for FoodLoop
/// Centralized configuration for all Cloudinary operations
class CloudinaryConfig {
  // Your Cloudinary cloud name
  static const String cloudName = 'dvjqnfreo';

  // Your Cloudinary upload preset name
  // Make sure this preset exists in your Cloudinary console
  // and is set to "Unsigned" mode for client-side uploads
  static const String uploadPreset = 'foodloop';

  // Base folder for all uploads
  static const String baseFolder = 'foodloop';

  // Profile images folder
  static const String profileImagesFolder = '$baseFolder/profile_images';

  // Food listing images folder (for future use)
  static const String listingImagesFolder = '$baseFolder/listings';
}

