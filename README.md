# Becomap Flutter SDK

A comprehensive Flutter SDK for integrating Becomap's interactive 3D mapping and indoor navigation capabilities into Flutter applications.

## Features

### 🗺️ **Interactive 3D Maps**
- High-performance 3D indoor maps with WebGL rendering
- Real-time map interactions and navigation
- Multi-floor building support with floor switching
- Smooth zoom, pan, and rotation controls

### 🧭 **Indoor Navigation**
- Turn-by-turn indoor navigation
- Real-time location tracking
- Route optimization and pathfinding
- Accessibility-aware routing options

### 🎨 **Customizable UI**
- Configurable map themes and styling
- Custom color schemes and branding
- Flexible control placement and visibility
- Responsive design for all screen sizes

### 🔧 **Developer-Friendly**
- Simple integration with builder pattern APIs
- Comprehensive error handling and debugging
- TypeScript-like configuration options
- Hot reload support for rapid development

### 🔒 **Enterprise Security**
- Secure API authentication
- Environment-based configuration
- No hardcoded credentials
- SOC 2 compliant infrastructure

### 📱 **Cross-Platform**
- iOS and Android support
- Consistent behavior across platforms
- Native performance with Flutter
- WebView-based rendering engine

## Quick Setup

### Prerequisites
- Flutter SDK 3.35.0 or higher
- Dart 3.5.0 or higher
- iOS 17.0+ / Android API 21+
- Becomap API credentials

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/becomap_flutter.git
   cd becomap_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   cp .example.env .env
   # Edit .env with your Becomap credentials
   ```

4. **Run the application**

   **iOS (Optimized with Auto-Run):**
   ```bash
   ./run_ios.sh
   ```

   **Android:**
   ```bash
   flutter run
   ```

## ⚡ iOS Auto-Run Development Setup

### VS Code Extension (Recommended for iOS)
1. **Install "Run on Save" extension**
   - Open VS Code Extensions (Cmd+Shift+X)
   - Search for "Run on Save" by `emeraldwalk`
   - Install the extension

2. **Configuration is pre-configured** in `.vscode/settings.json`:
   ```json
   {
     "emeraldwalk.runonsave": {
       "commands": [
         {
           "match": "\\.(dart|yaml|env)$",
           "cmd": "./run_ios.sh",
           "runIn": "terminal",
           "runningStatusMessage": "🔄 Building Flutter app...",
           "finishStatusMessage": "✅ Flutter app ready!"
         }
       ]
     },
     "flutter.debugExternalPackageLibraries": true,
     "flutter.debugSdkLibraries": false
   }
   ```

3. **Usage**
   - Save any `.dart`, `.yaml`, or `.env` file (Cmd+S)
   - App automatically rebuilds and runs in iOS Simulator
   - Status messages appear in VS Code status bar

## Environment Configuration

The SDK uses environment variables for secure configuration management.

### Required Environment Variables

Create a `.env` file in the project root with the following variables:

```env
# Becomap API Configuration
BECOMAP_CLIENT_ID=your_client_id_here
BECOMAP_CLIENT_SECRET=your_client_secret_here
BECOMAP_SITE_IDENTIFIER=your_site_identifier_here
```

### Getting API Credentials

1. Sign up for a Becomap developer account
2. Create a new project in the Becomap dashboard
3. Generate API credentials for your project
4. Copy the credentials to your `.env` file

**⚠️ Important**: Never commit the `.env` file to version control. Use `.example.env` as a template.

## Development

### Project Structure
```
becomap_flutter/
├── lib/                    # Main application code
├── packages/
│   └── becomap/  # SDK package
├── android/                # Android-specific code
├── ios/                    # iOS-specific code
├── test/                   # Unit tests
├── .env                    # Environment variables (not in git)
├── .vscode/                # VS Code settings
└── run_ios.sh             # Optimized iOS build script
```

### Building

#### iOS (Optimized)
```bash
# Optimized iOS build with auto-detection
./run_ios.sh

# Manual iOS build
flutter build ios --debug
flutter build ios --release
```

**iOS Script Features:**
- **Auto-detects** available iPhone simulators (no hardcoded UUIDs)
- **Smart caching** - skips clean/rebuild when unnecessary
- **Portable** across different development machines
- **Complete workflow**: simulator boot → build → launch
- Finds first available iPhone 15 Pro (or falls back to any iPhone)
- Works on any machine with Xcode installed

#### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

### Testing

#### Run Unit Tests
```bash
flutter test
```

#### Run Package Tests
```bash
cd packages/becomap
flutter test
```

#### Run Integration Tests
```bash
flutter test integration_test/
```

### Code Quality

The project uses comprehensive pre-commit hooks for code quality:

#### Manual Code Quality Checks
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run all pre-commit hooks
pre-commit run --all-files
```

#### Security Scanning
```bash
# Scan for secrets
detect-secrets scan --all-files

# Check for vulnerabilities
flutter pub deps
```

### Package Development

The SDK is structured as a separate Flutter package for easy distribution:

#### Package Commands
```bash
cd packages/becomap

# Install dependencies
flutter pub get

# Run tests
flutter test

# Publish (dry run)
flutter packages pub publish --dry-run
```

## CI/CD

The project includes GitHub Actions workflows for:

- **Automated Testing**: Unit tests, integration tests, and code analysis
- **Security Scanning**: Secret detection, vulnerability scanning, and dependency checks
- **Quality Gates**: SonarQube integration for code quality metrics
- **Build Verification**: Multi-platform build validation
- **Automated Deployment**: Package publishing and release management

### Required GitHub Secrets

For CI/CD to work properly, configure these secrets in your GitHub repository:

```
SONAR_TOKEN          # SonarQube authentication token
SONAR_HOST_URL       # SonarQube server URL
GITGUARDIAN_API_KEY  # GitGuardian API key for secret scanning
```

## Troubleshooting

### iOS Development
#### VS Code Extension not working?
1. Check if "Run on Save" extension is installed and enabled
2. Reload VS Code window (Cmd+Shift+P → "Developer: Reload Window")
3. Check VS Code's Output panel for error messages

#### Simulator not found?
1. Open Xcode and install iOS Simulator
2. Run `xcrun simctl list devices` to see available simulators
3. The script will automatically find and use any available iPhone

### General Issues
#### Build errors?
1. Run `flutter doctor` to check Flutter installation
2. Clean project: `flutter clean && flutter pub get`
3. Check `.env` file has valid credentials

## Contributing

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** (ensure all pre-commit hooks pass)
4. **Run tests** (`flutter test`)
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### Development Guidelines

- Follow Flutter/Dart style guidelines
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure all CI/CD checks pass
- Use semantic commit messages

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [Coming Soon]
- **Issues**: [GitHub Issues](https://github.com/your-org/becomap_flutter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/becomap_flutter/discussions)
- **Email**: support@becomap.com

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.
