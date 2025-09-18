# MindsEye Flutter App

## 🎯 Overview

The MindsEye Flutter application is a comprehensive mobile platform for child psychology assessment. It provides role-based interfaces for professionals, teachers, parents, and administrators to manage and analyze children's psychological assessments through drawing analysis.

## 📱 Features

### 🔐 Multi-Role Authentication
- **Professional**: Psychologists and mental health professionals
- **Teacher**: School teachers and educators
- **Parent**: Parents and guardians
- **School Admin**: School administrators
- **NGO Admin**: NGO administrators

### 🎨 Drawing Assessment
- Capture children's drawings using device camera
- Submit drawings for AI-powered analysis
- Manual labeling and scoring capabilities
- Progress tracking and history

### 📊 Reports & Analytics
- Comprehensive report dashboard
- Filtering by school, score, age, and date range
- Visual progress indicators
- Export and sharing capabilities

### 👥 User Management
- Admin dashboard for managing teachers and students
- School assignment and management
- Profile editing and settings
- Role-based access control

### 📈 Data Visualization
- Charts and graphs for analytics
- Performance metrics
- Trend analysis
- Comparative reporting

## 🛠️ Prerequisites

- **Flutter** (v3.5 or higher)
- **Dart** (v3.5 or higher)
- **Android Studio** or **VS Code**
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Git**

## 🚀 Installation & Setup

### 1. Clone and Navigate
```bash
cd mindseye_now/mindseye
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
Create a `.env` file in the `lib` directory:

```env
# Backend API Configuration
BACKEND_URL=http://localhost:3001

# Optional: Twilio Configuration (for SMS)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=your_twilio_phone_number
```

### 4. Platform Setup

#### Android Setup
1. Ensure Android SDK is installed
2. Set up Android emulator or connect physical device
3. Run `flutter doctor` to verify setup

#### iOS Setup (macOS only)
1. Install Xcode from App Store
2. Install iOS Simulator
3. Run `flutter doctor` to verify setup

### 5. Run the Application
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific platform
flutter run -d android
flutter run -d ios
```

## 📱 App Structure

### Core Screens

#### Authentication
- `login.dart` - Main login screen
- `sendotp.dart` - OTP verification
- `NGOlogin.dart` - NGO admin login
- `professionalLogin.dart` - Professional login
- `schoolLogin.dart` - School admin login

#### Dashboards
- `adminDahboard.dart` - Admin dashboard
- `professionalDashboard.dart` - Professional dashboard
- `teacherDashboard.dart` - Teacher dashboard
- `parentDashboard.dart` - Parent dashboard
- `schoolDashboard.dart` - School dashboard
- `NGOdashboard.dart` - NGO dashboard

#### Assessment
- `captureDrawing.dart` - Drawing capture interface
- `tagImage.dart` - Image tagging and analysis
- `tagImageManuaaly.dart` - Manual image labeling
- `question.dart` - Assessment questionnaire

#### Reports
- `reportsDashboard.dart` - Main reports interface
- `reportDetails.dart` - Individual report view
- `childReportDetails.dart` - Child-specific reports
- `reportAnalysis.dart` - Analytics and charts

#### Management
- `createadminaccount.dart` - Admin account creation
- `createProfessionalAccount.dart` - Professional account creation
- `createSchoolAccount.dart` - School account creation
- `uploadTeacherDetails.dart` - Teacher management
- `uploadChildDetails.dart` - Student management
- `assignadmintoschool.dart` - School assignment
- `AssignSchoolToProfessionalScreen.dart` - Professional assignment

#### Data & History
- `labelDataScreen.dart` - Data labeling interface
- `labelPreviousData.dart` - Historical data management
- `previousSubmission.dart` - Submission history
- `submissionStatus.dart` - Status tracking

#### Profile & Settings
- `EditProfileScreen.dart` - Profile editing
- `selectChild.dart` - Child selection interface

### Key Components

#### Shared Preferences Helper
- `shared_prefs_helper.dart` - Local data storage management

#### Styles
- `styles.dart` - App-wide styling and themes

## 🔧 Configuration

### Dependencies
The app uses the following key dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.3.0                    # API communication
  shared_preferences: ^2.2.2      # Local storage
  image_picker: ^1.1.2           # Image capture
  flutter_dotenv: ^5.2.1         # Environment variables
  intl: ^0.20.0                  # Date formatting
  fl_chart: ^1.0.0               # Charts and graphs
  twilio_flutter: ^0.9.0         # SMS functionality
  shimmer: ^3.0.0                # Loading animations
  animate_do: ^3.0.0             # Animations
  provider: ^6.1.1               # State management
  libphonenumber: ^2.0.1         # Phone number formatting
```

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `BACKEND_URL` | Backend API URL | Yes | http://localhost:3001 |
| `TWILIO_ACCOUNT_SID` | Twilio account SID | No | - |
| `TWILIO_AUTH_TOKEN` | Twilio auth token | No | - |
| `TWILIO_PHONE_NUMBER` | Twilio phone number | No | - |

## 🎨 UI/UX Features

### Design System
- **Material Design 3** components
- **Responsive layout** for different screen sizes
- **Dark/Light theme** support
- **Accessibility** features

### Key UI Components
- **Custom buttons** with consistent styling
- **Loading indicators** and animations
- **Error handling** with user-friendly messages
- **Form validation** with real-time feedback
- **Navigation drawer** for easy access

### Color Scheme
- **Primary**: Blue (#2196F3)
- **Secondary**: Black (#000000)
- **Accent**: Orange (#FF9800)
- **Success**: Green (#4CAF50)
- **Error**: Red (#F44336)

## 🔐 Security Features

### Authentication
- **Phone number-based** authentication
- **OTP verification** for secure login
- **Role-based access** control
- **Session management** with local storage

### Data Protection
- **Secure API communication** with HTTPS
- **Input validation** and sanitization
- **Error handling** without exposing sensitive data
- **Local data encryption** for stored preferences

## 📊 Data Management

### Local Storage
- **Shared Preferences** for user data
- **Session management** for authentication
- **Offline capability** for basic functionality
- **Data synchronization** when online

### API Integration
- **RESTful API** communication
- **JSON data** handling
- **Error handling** and retry logic
- **Loading states** and progress indicators

## 🚀 Building for Production

### Android Build
```bash
# Generate APK
flutter build apk --release

# Generate App Bundle
flutter build appbundle --release
```

### iOS Build
```bash
# Generate iOS app
flutter build ios --release
```

### Web Build
```bash
# Generate web app
flutter build web --release
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 📱 Platform Support

### Android
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 33 (Android 13)
- **Permissions**: Camera, Storage, Internet

### iOS
- **Minimum Version**: iOS 12.0
- **Target Version**: iOS 16.0
- **Permissions**: Camera, Photo Library, Internet

### Web
- **Modern browsers** (Chrome, Firefox, Safari, Edge)
- **Responsive design** for different screen sizes

## 🔧 Development Guidelines

### Code Structure
```
lib/
├── main.dart                 # App entry point
├── shared_prefs_helper.dart  # Local storage helper
├── styles.dart              # App styling
├── [screen_name].dart       # Individual screens
└── assets/
    ├── images/              # Image assets
    └── .env                 # Environment variables
```

### Naming Conventions
- **Files**: snake_case (e.g., `admin_dashboard.dart`)
- **Classes**: PascalCase (e.g., `AdminDashboard`)
- **Variables**: camelCase (e.g., `userDetails`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)

### State Management
- **Provider** for app-wide state
- **Local state** for component-specific data
- **Shared Preferences** for persistent data

## 🐛 Troubleshooting

### Common Issues

1. **Flutter Doctor Issues**
   ```bash
   flutter doctor
   # Follow the recommendations to fix issues
   ```

2. **Dependency Issues**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build Issues**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **API Connection Issues**
   - Verify backend server is running
   - Check `BACKEND_URL` in `.env` file
   - Ensure network connectivity

5. **Permission Issues**
   - Check app permissions in device settings
   - Verify camera and storage permissions

### Debug Mode
```bash
flutter run --debug
```

### Verbose Logging
```bash
flutter run -v
```

## 📊 Performance Optimization

### Best Practices
- **Lazy loading** for large lists
- **Image optimization** and caching
- **Memory management** for image processing
- **Network request** optimization
- **State management** efficiency

### Monitoring
- **Performance profiling** with Flutter DevTools
- **Memory usage** monitoring
- **Network request** tracking
- **Error tracking** and reporting

## 🔄 Updates & Maintenance

### Dependency Updates
```bash
flutter pub upgrade
flutter pub outdated
```

### Code Analysis
```bash
flutter analyze
```

### Formatting
```bash
flutter format .
```

## 📞 Support

### Getting Help
- Check the troubleshooting section above
- Review Flutter documentation
- Create an issue in the repository
- Contact the development team

### Useful Commands
```bash
flutter doctor          # Check Flutter installation
flutter pub get         # Install dependencies
flutter clean           # Clean build cache
flutter run             # Run the app
flutter build apk       # Build Android APK
flutter build ios       # Build iOS app
```

## 📄 License

This project is licensed under the Apache License 2.0.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**MindsEye Flutter App** - Empowering child psychology assessment through mobile technology.
