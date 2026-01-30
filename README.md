# SmartParking

A smart parking mobile app for finding spaces faster using IoT and data analytics. Written in Dart with Flutter and C# with ASP.NET.

## Features

- 🚗 Real-time parking space availability detection
- 📱 Cross-platform mobile app (iOS & Android)
- 🔌 Arduino-based IoT sensor integration
- ☁️ Cloud-based backend with MongoDB
- 🔐 Secure authentication with JWT
- 🌐 Supports any platform and device

## Architecture

- **Mobile App**: Flutter (Dart) - iOS, Android, Web
- **Backend**: ASP.NET Core (C#) - REST API
- **Database**: MongoDB
- **Hardware**: Arduino with light sensors
- **Deployment**: Docker support

## Quick Start

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (for mobile app)
- [.NET 9.0 SDK](https://dotnet.microsoft.com/download) (for backend)
- [MongoDB](https://www.mongodb.com/try/download/community) (or use Docker)
- [Arduino IDE](https://www.arduino.cc/en/software) (for hardware integration)

### Running the Backend

```bash
cd backend

# Install dependencies
dotnet restore

# Run the server
dotnet run
```

The backend will be available at `http://localhost:8080`

### Running the Mobile App

```bash
cd mobile-ui

# Install dependencies
flutter pub get

# Run on Android emulator
flutter run

# Or run on iOS simulator
flutter run -d ios

# Or build for release
flutter build apk  # Android
flutter build ios  # iOS
```

### Hardware Integration

See [HARDWARE_SETUP.md](HARDWARE_SETUP.md) for detailed hardware setup instructions.

## Configuration

### Backend Configuration

Copy `.env.example` to `.env` and configure:

```bash
cd backend
cp .env.example .env
# Edit .env with your settings
```

Key configurations:
- **MongoDB**: Connection string for database
- **JWT_SECRET**: Secret key for authentication
- **Serial Port**: Arduino connection (auto-detected if not specified)

### Mobile App Configuration

The app automatically adapts to the platform:
- **Android Emulator**: Uses `http://10.0.2.2:8080/api`
- **iOS Simulator**: Uses `http://localhost:8080/api`
- **Physical Device**: Configure via build arguments

For production deployment:
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-api.com/api
```

## Cross-Platform Support

### Supported Platforms

#### Mobile App
- ✅ Android (5.0+)
- ✅ iOS (11.0+)
- ✅ Web (with limitations on sensor access)

#### Backend
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Docker containers

#### Hardware
- ✅ Arduino Uno/Nano
- ✅ Any board with serial communication
- ✅ Works without hardware (graceful degradation)

### Platform-Specific Notes

#### Android
- Internet permissions included
- Minimum SDK: API 23 (Android 6.0)
- Release builds require signing configuration

#### iOS
- HTTP connections allowed for local development
- Requires Xcode for building
- Simulator and physical device supported

#### Backend Serial Ports
- **Windows**: COM3, COM4, etc.
- **Linux**: /dev/ttyUSB0, /dev/ttyACM0, etc.
- **macOS**: /dev/cu.usbserial*, /dev/cu.usbmodem*

## Development

### Project Structure

```
SmartParking/
├── mobile-ui/              # Flutter mobile application
│   ├── lib/
│   │   ├── core/          # Constants, theme
│   │   ├── models/        # Data models
│   │   ├── services/      # API & sensor services
│   │   ├── providers/     # State management
│   │   ├── views/         # UI screens
│   │   ├── widgets/       # Reusable components
│   │   └── routes/        # Navigation
│   ├── android/           # Android-specific config
│   └── ios/               # iOS-specific config
├── backend/               # ASP.NET Core API
│   ├── Controllers/       # API endpoints
│   ├── Models/           # Data models
│   ├── Services/         # Business logic
│   └── Data/             # Database context
├── arduino-code/         # Arduino sensor firmware
└── senior-design-project-docs/  # Documentation
```

### Testing

```bash
# Backend tests
cd backend
dotnet test

# Mobile app tests
cd mobile-ui
flutter test

# Run with coverage
flutter test --coverage
```

### Linting

```bash
# Backend
cd backend
dotnet format

# Mobile app
cd mobile-ui
flutter analyze
```

## Deployment

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up --build
```

### Cloud Deployment

The application is designed for cloud deployment:
- Backend can be deployed to Azure, AWS, or any cloud platform
- Mobile app can be published to Google Play Store and Apple App Store
- MongoDB can use Atlas or any cloud database

## Troubleshooting

### Common Issues

1. **"Serial port not found"**
   - Ensure Arduino is connected
   - Check port permissions on Linux
   - See HARDWARE_SETUP.md for details

2. **"Connection refused" on mobile app**
   - Verify backend is running
   - Check firewall settings
   - For physical devices, use computer's IP address

3. **Build failures**
   - Run `flutter clean` and `flutter pub get`
   - Update Flutter SDK: `flutter upgrade`
   - Check platform-specific requirements

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on all platforms
5. Submit a pull request

## License

This project was developed as a senior design project at the University of Cincinnati.

## Authors

- Owen Edwards
- Andrew Pipo

## Documentation

Additional documentation is available in the `senior-design-project-docs/` directory:
- Project abstract
- Design diagrams
- User stories
- Research and timeline

For user manual, visit: [pipoat.github.io/cs5002.html](https://pipoat.github.io/cs5002.html)
 