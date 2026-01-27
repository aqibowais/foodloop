# Cloudinary Setup Guide for FoodLoop

## Fixing the 400 Error on Image Upload

The 400 error you're seeing means Cloudinary is rejecting the upload request. This is usually due to upload preset configuration issues.

### Step 1: Verify Your Cloudinary Account

1. Go to [Cloudinary Console](https://console.cloudinary.com/)
2. Log in with your account
3. Note your **Cloud Name** (should be `dvjqnfreo` based on your config)

### Step 2: Create/Configure Upload Preset

1. In Cloudinary Console, go to **Settings** → **Upload**
2. Scroll down to **Upload presets**
3. Check if a preset named `foodloop` exists:
   - **If it exists**: Click on it and verify settings (see Step 3)
   - **If it doesn't exist**: Click **Add upload preset** and name it `foodloop`

### Step 3: Configure Upload Preset Settings

For the `foodloop` preset, configure these settings:

#### Required Settings:
- **Preset name**: `foodloop`
- **Signing mode**: **Unsigned** (important! This allows client-side uploads)
- **Folder**: `profile_images` (optional, but recommended)
- **Use filename**: Enabled (recommended)
- **Unique filename**: Enabled (recommended)

#### Optional but Recommended:
- **Allowed formats**: `jpg, png, webp`
- **Max file size**: `10 MB` (or your preferred limit)
- **Eager transformations**: None (we'll transform on-the-fly when displaying)

### Step 4: Verify Upload Preset is Active

1. Make sure the preset is **Active** (not disabled)
2. Save the preset
3. The preset should now appear in your list of upload presets

### Step 5: Test the Upload

After configuring the preset, try uploading a profile image again. The 400 error should be resolved.

### Common Issues and Solutions

#### Issue: "400 Bad Request"
- **Cause**: Upload preset doesn't exist or is misconfigured
- **Solution**: Create/configure the preset as described above

#### Issue: "401 Unauthorized"
- **Cause**: Wrong cloud name or upload preset name
- **Solution**: Verify `cloudName: 'dvjqnfreo'` and `uploadPreset: 'foodloop'` in `profile_provider.dart`

#### Issue: "413 File Too Large"
- **Cause**: Image file exceeds Cloudinary's size limit
- **Solution**: The app already compresses images to max 800x800px, but you can reduce further in `profile_screen.dart` line 63-64

#### Issue: Upload Preset Requires Signing
- **Cause**: Preset is set to "Signed" mode
- **Solution**: Change preset to **"Unsigned"** mode in Cloudinary Console

### Alternative: Use Signed Uploads (More Secure)

If you prefer signed uploads (more secure but requires backend):

1. Keep preset as **Signed**
2. Generate upload signature on your backend
3. Pass signature to client
4. Update `StorageService` to include signature in upload

For MVP, **unsigned uploads are fine** and easier to implement.

### Current Configuration

Your Cloudinary configuration is now centralized in `lib/core/config/cloudinary_config.dart`:
```dart
class CloudinaryConfig {
  static const String cloudName = 'dvjqnfreo';
  static const String uploadPreset = 'foodloop';
}
```

**To update your Cloudinary credentials**, edit this file. All services automatically use this configuration.

Make sure these values match exactly what's in your Cloudinary Console.

### Testing

After setup, test with a small image (< 2MB) first. The app will:
1. Compress image to max 800x800px
2. Upload to Cloudinary folder: `profile_images/{userId}`
3. Return secure URL for storage in Firestore

### Need Help?

- Check Cloudinary logs in Console → Media Library → Activity
- Review error messages in Flutter console (now with enhanced logging)
- Verify preset name matches exactly (case-sensitive)

