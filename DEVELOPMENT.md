# Development Guide

## Git Setup and Pre-commit Hooks

This project uses comprehensive pre-commit hooks to ensure code quality, security, and compliance with SonarQube requirements.

### Pre-commit Hooks Installed

#### ✅ **Code Quality Hooks**
- **Trailing whitespace removal**: Automatically removes trailing whitespace
- **End-of-file fixer**: Ensures files end with a newline
- **YAML/JSON syntax checking**: Validates configuration files
- **Merge conflict detection**: Prevents committing merge conflict markers
- **Large file detection**: Prevents committing files larger than 1MB
- **Private key detection**: Scans for accidentally committed private keys

#### ✅ **Dart/Flutter Specific Hooks**
- **Dart formatting**: Automatically formats Dart code using `dart format`
- **Dart analysis**: Runs `flutter analyze` to catch potential issues
- **Flutter tests**: Runs unit tests for the package

#### ✅ **Security Hooks**
- **Secret detection**: Uses detect-secrets to find high-entropy strings
- **Private key detection**: Prevents committing SSH keys, certificates, etc.

### SonarQube Integration

The project is configured for SonarQube analysis with:

- **Coverage reporting**: Generates LCOV coverage reports
- **Code quality metrics**: Tracks technical debt, bugs, vulnerabilities
- **Security hotspots**: Identifies potential security issues
- **Duplication detection**: Finds code duplication

Configuration file: `sonar-project.properties`

### CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/ci.yml`) includes:

#### 🧪 **Test Job**
- Flutter dependency installation
- Code formatting verification
- Static analysis with `flutter analyze`
- Unit test execution with coverage
- SonarQube scanning

#### 🔒 **Security Job**
- Trivy vulnerability scanning
- GitGuardian secret detection
- SARIF report generation for GitHub Security tab

#### 🏗️ **Build Job**
- APK build verification
- Package publishing dry-run
- Artifact upload

### Development Workflow

#### 1. **Making Changes**
```bash
# Make your changes
git add .
git commit -m "Your commit message"
```

The pre-commit hooks will automatically:
- Format your Dart code
- Run static analysis
- Execute tests
- Check for security issues
- Validate file formats

#### 2. **If Hooks Fail**
- Fix the issues reported by the hooks
- Re-run `git add .` and `git commit`
- The hooks will run again automatically

#### 3. **Manual Hook Execution**
```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run dart-format
pre-commit run flutter-test
```

### Security Best Practices

#### 🔐 **API Keys and Secrets**
- Never commit API keys, passwords, or secrets
- Use environment variables for sensitive data
- The hooks will detect and prevent most secret commits

#### 🛡️ **Dependencies**
- Keep dependencies updated
- Review security advisories
- Use `flutter pub deps` to check dependency tree

#### 📝 **Code Review**
- All changes should go through pull requests
- CI/CD pipeline must pass before merging
- SonarQube quality gate must pass

### Configuration Files

- **`.pre-commit-config.yaml`**: Pre-commit hook configuration
- **`sonar-project.properties`**: SonarQube analysis configuration
- **`.secrets.baseline`**: Baseline for secret detection
- **`.github/workflows/ci.yml`**: CI/CD pipeline configuration

### Troubleshooting

#### Pre-commit Issues
```bash
# Update pre-commit hooks
pre-commit autoupdate

# Clear pre-commit cache
pre-commit clean

# Reinstall hooks
pre-commit install
```

#### Test Failures
```bash
# Run tests manually
flutter test
cd packages/becomap && flutter test

# Run with coverage
flutter test --coverage
```

#### SonarQube Setup
1. Set up SonarQube server or use SonarCloud
2. Configure `SONAR_TOKEN` and `SONAR_HOST_URL` secrets in GitHub
3. Update `sonar-project.properties` with your project key

This setup ensures enterprise-grade code quality and security compliance for the Becomap Flutter SDK.
