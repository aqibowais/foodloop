# FoodLoop 🍽️

**Pakistan's First Food Sharing App**

FoodLoop is a Flutter-based mobile application that connects food donors with receivers to reduce food waste and feed those in need. Built with Firebase backend, it enables users to share surplus food, request food items, and track their impact on the community.

## 📱 Features

### Core Functionality

- **User Authentication**
  - Email/Password authentication
  - Google Sign-In integration
  - User profile management with role-based access (User/Admin)

- **Food Listings**
  - Create listings with food type (Cooked, Packaged, Bakery, Beverages)
  - Upload multiple images via Cloudinary
  - Set expiry dates and serving quantities
  - Location-based listing (City/Area)
  - Status lifecycle: Available → Reserved → Completed/Expired

- **Request Management**
  - Receivers can send requests to donors
  - Donors can accept/reject requests
  - Real-time request status updates
  - Contact functionality for accepted requests (phone/email)

- **Complaints & Reporting**
  - Submit complaints linked to listings or transactions
  - Category-based reporting (Food Quality, Pickup Issue, User Behavior, Listing Issue, Other)
  - Status tracking: Submitted → Under Review → Resolved

- **Admin Dashboard**
  - View all complaints and manage their status
  - Analytics with charts (listings, requests, users, complaints)
  - Visual data representation using fl_chart

- **Impact Tracking**
  - Donor metrics (completed donations, estimated meals served)
  - Receiver metrics (successful pickups)

- **Notifications**
  - Real-time updates for listings and requests
  - Notification center for user activities

## 🛠️ Tech Stack

### Frontend
- **Flutter** (SDK: ^3.9.0)
- **Riverpod** - State management
- **Google Fonts (Lexend)** - Typography
- **fl_chart** - Data visualization

### Backend
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Database
- **Cloudinary** - Image storage and CDN

### Key Packages
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
google_sign_in: ^6.2.1
flutter_riverpod: ^2.5.1
cloudinary_public: ^0.23.0
image_picker: ^1.1.2
url_launcher: ^6.3.1
intl: ^0.19.0
shared_preferences: ^2.2.2
google_fonts: ^6.2.1
fl_chart: ^0.69.0
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/              # Data models
│   │   ├── food_listing_model.dart
│   │   ├── food_request_model.dart
│   │   ├── user_model.dart
│   │   ├── complaint_model.dart
│   │   └── rating_model.dart
│   ├── services/            # Core services
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   └── onboarding_service.dart
│   ├── providers/          # Core providers
│   ├── theme/              # App theming
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   ├── utils/              # Utilities
│   │   ├── constants.dart
│   │   ├── phone_validator.dart
│   │   └── app_toast.dart
│   └── navigation/        # Navigation utilities
│
├── features/
│   ├── auth/               # Authentication
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       ├── login_screen.dart
│   │   │       └── signup_screen.dart
│   │   ├── providers/
│   │   └── services/
│   │
│   ├── onboarding/        # Onboarding flow
│   │   └── presentation/
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           └── intro_screen.dart
│   │
│   ├── home/               # Home & Navigation
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       ├── home_screen.dart
│   │   │       ├── main_navigation_screen.dart
│   │   │       ├── notifications_screen.dart
│   │   │       └── report_screen.dart
│   │   └── providers/
│   │       └── complaint_provider.dart
│   │
│   ├── listings/           # Food listings
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       ├── create_listing_screen.dart
│   │   │       ├── edit_listing_screen.dart
│   │   │       └── listing_detail_screen.dart
│   │   ├── providers/
│   │   └── services/
│   │
│   ├── profile/            # User profile
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       └── profile_screen.dart
│   │   ├── providers/
│   │   └── services/
│   │
│   ├── user/               # User management
│   │   └── providers/
│   │
│   └── admin/              # Admin features
│       ├── presentation/
│       │   └── screens/
│       │       └── admin_dashboard_screen.dart
│       ├── providers/
│       └── services/
│
├── app.dart                # Main app wrapper
└── main.dart               # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK (3.9.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase project setup
- Cloudinary account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd foodloop
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Cloudinary Setup**
   - Create a Cloudinary account at [Cloudinary](https://cloudinary.com/)
   - Create an unsigned upload preset
   - Configure in `lib/core/services/storage_service.dart`:
     ```dart
     static const String cloudName = 'your-cloud-name';
     static const String uploadPreset = 'your-upload-preset';
     ```

5. **Firestore Security Rules**
   - Deploy security rules from `firestore.rules`
   - Create necessary composite indexes as prompted by Firestore

6. **Run the app**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Firebase Configuration

1. **Authentication**
   - Enable Email/Password authentication
   - Enable Google Sign-In
   - Configure OAuth consent screen for Google Sign-In

2. **Firestore**
   - Create collections: `users`, `listings`, `requests`, `complaints`, `ratings`
   - Deploy security rules (see `firestore.rules`)
   - Create composite indexes as needed:
     - `listings`: `status` + `expiryDate`
     - `requests`: `listingId` + `status` + `donorId`/`receiverId`

3. **Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow authenticated users to read/write
       match /{document=**} {
         allow read, write, list: if request.auth != null;
       }
     }
   }
   ```

### Cloudinary Configuration

1. Create an unsigned upload preset:
   - Go to Cloudinary Dashboard → Settings → Upload
   - Create a new upload preset
   - Set it as "Unsigned"
   - Configure allowed formats and max file size

2. Update `storage_service.dart` with your credentials

## 📊 Data Models

### UserModel
- `uid`, `email`, `displayName`, `photoUrl`
- `role` (User/Admin)
- `city`, `area`, `organizationName`
- `phoneNumber` (Pakistani format)
- `impactStats` (for future use)

### FoodListing
- `id`, `donorId`, `foodType`, `title`, `description`
- `servings`, `expiryDate`, `city`, `area`
- `imageUrls`, `status` (Available/Reserved/Completed/Expired)
- `createdAt`, `updatedAt`, `completedAt`, `expiredAt`

### FoodRequest
- `id`, `listingId`, `donorId`, `receiverId`
- `status` (Pending/Accepted/Rejected)
- `message`, `createdAt`, `respondedAt`

### Complaint
- `id`, `listingId`, `complainantId`, `againstUserId`
- `category`, `description`, `status`
- `createdAt`, `resolvedAt`, `adminNotes`

### Rating
- `id`, `listingId`, `raterId`, `ratedUserId`
- `stars` (1-5), `comment`, `createdAt`

## 🎨 UI/UX

### Theme
- **Dark Mode** with neon accents
- Primary color: Green (`#00FF88`)
- Background: Black (`#000000`)
- Card background: Dark gray (`#1A1A1A`)
- Typography: Lexend font family

### Navigation
- **Bottom Navigation Bar** (persistent across screens)
  - Home
  - Notifications
  - Report
  - Profile

### Key Screens
- **Splash Screen** - App initialization
- **Onboarding** - 3-screen introduction
- **Home** - Listings feed with filters
- **Listing Detail** - Full listing information
- **Create/Edit Listing** - Listing management
- **Profile** - User profile management
- **Report** - Complaint submission
- **Notifications** - User notifications
- **Admin Dashboard** - Analytics and complaint management

## 🔐 Security

- Firebase Authentication for user management
- Firestore security rules (app-level validation)
- Input validation on all forms
- Phone number validation (Pakistani format)
- Image upload validation

## 🧪 Development

### State Management
- **Riverpod** for all state management
- `StreamProvider` for real-time data
- `FutureProvider` for async operations
- `StateNotifierProvider` for complex state

### Key Providers
- `authStateProvider` - Authentication state
- `currentUserProvider` - Current user
- `availableListingsProvider` - Available listings stream
- `listingRequestsProvider` - Listing requests stream
- `userControllerProvider` - User data management
- `listingsControllerProvider` - Listing operations
- `complaintControllerProvider` - Complaint management
- `adminAnalyticsProvider` - Admin analytics

### Error Handling
- Try-catch blocks in all service methods
- Graceful error handling in providers
- User-friendly error messages via `AppToast`
- Debug logging for troubleshooting

## 📝 Features by Module

### Module 1: Authentication & Onboarding
- ✅ Email/Password authentication
- ✅ Google Sign-In
- ✅ Onboarding flow (3 screens)
- ✅ Splash screen

### Module 2: User Profiles
- ✅ Profile creation/editing
- ✅ Role selection (User/Admin)
- ✅ Profile image upload
- ✅ Location (City/Area)
- ✅ Organization name
- ✅ Phone number (Pakistani validation)

### Module 3: Food Listings
- ✅ Create listing with all details
- ✅ Image upload via Cloudinary
- ✅ Status lifecycle management
- ✅ Listing discovery with filters
- ✅ Edit/Delete listings

### Module 4: Request Management
- ✅ Send requests
- ✅ Accept/Reject requests
- ✅ Real-time request updates
- ✅ Contact functionality (phone/email)
- ✅ Request count display

### Module 5: Completion, Complaints, Ratings & Impact
- ✅ Completion flow (Complete/Expired)
- ✅ Complaints system
- ✅ Admin panel for complaints
- ✅ Ratings system (models ready)
- ✅ Impact dashboard (models ready)

## 🐛 Troubleshooting

### Listings Not Showing
- Check Firestore security rules
- Verify listing status is "available"
- Check if listings are expired (past expiryDate)
- Review console logs for filtering details
- Ensure Firestore indexes are created

### Image Upload Failing
- Verify Cloudinary credentials
- Check upload preset is "Unsigned"
- Ensure preset allows the image format
- Check file size limits

### Authentication Issues
- Verify Firebase configuration files
- Check Google Sign-In OAuth setup
- Ensure email/password auth is enabled

## 📱 Platform Support

- **Android** - Fully supported
- **iOS** - Supported (requires iOS setup)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is private and proprietary.

## 👥 Team

Developed for Pakistan's first food sharing platform.

## 🔮 Future Enhancements

- [ ] Push notifications
- [ ] In-app messaging
- [ ] Map integration for location
- [ ] Rating system UI
- [ ] Impact dashboard UI
- [ ] Social sharing
- [ ] Multi-language support
- [ ] Offline mode

## 📞 Support

For issues and questions, please contact the development team.

---

**Made with ❤️ for Pakistan**
