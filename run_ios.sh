#!/bin/bash

# BeCoMap Flutter iOS Runner Script
# Automatically finds and runs on the latest iOS version available
# Priority: iPhone 16 Pro (iOS 18.5) > iPhone 16 Pro (any iOS) > iPhone 15 Pro > Any iPhone

# Set PATH to prioritize Homebrew binaries
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

# Disable RVM temporarily
unset GEM_HOME
unset GEM_PATH
unset RUBY_VERSION

echo "🚀 Starting iOS Simulator setup (targeting latest iOS version)..."

# Function to find and boot simulator
find_and_boot_simulator() {
    echo "🔍 Finding available iOS simulators..."

    # Try to get iPhone 16 Pro with iOS 18.5 (latest) first
    IPHONE_16_PRO_UUID=$(xcrun simctl list devices | grep -A 20 "iOS 18.5" | grep "iPhone 16 Pro" | grep -v "Max" | head -1 | grep -o '[A-F0-9-]\{36\}')

    if [ -n "$IPHONE_16_PRO_UUID" ]; then
        echo "📱 Found iPhone 16 Pro (iOS 18.5) simulator: $IPHONE_16_PRO_UUID"
        SIMULATOR_UUID=$IPHONE_16_PRO_UUID
        SIMULATOR_NAME="iPhone 16 Pro"
    else
        # Fallback to iPhone 16 Pro with any iOS version
        IPHONE_16_PRO_UUID=$(xcrun simctl list devices | grep "iPhone 16 Pro" | grep -v "Max" | head -1 | grep -o '[A-F0-9-]\{36\}')

        if [ -n "$IPHONE_16_PRO_UUID" ]; then
            echo "📱 Found iPhone 16 Pro simulator: $IPHONE_16_PRO_UUID"
            SIMULATOR_UUID=$IPHONE_16_PRO_UUID
            SIMULATOR_NAME="iPhone 16 Pro"
        else
            # Fallback to iPhone 15 Pro
            IPHONE_15_PRO_UUID=$(xcrun simctl list devices | grep "iPhone 15 Pro" | grep -v "Max" | head -1 | grep -o '[A-F0-9-]\{36\}')

            if [ -n "$IPHONE_15_PRO_UUID" ]; then
                echo "📱 Found iPhone 15 Pro simulator: $IPHONE_15_PRO_UUID"
                SIMULATOR_UUID=$IPHONE_15_PRO_UUID
                SIMULATOR_NAME="iPhone 15 Pro"
            else
                echo "⚠️  Latest iPhone models not found, looking for any iPhone simulator..."
                # Final fallback to first available iPhone simulator
                IPHONE_UUID=$(xcrun simctl list devices | grep "iPhone" | head -1 | grep -o '[A-F0-9-]\{36\}')

                if [ -n "$IPHONE_UUID" ]; then
                    SIMULATOR_NAME=$(xcrun simctl list devices | grep "$IPHONE_UUID" | sed 's/.*iPhone/iPhone/' | sed 's/ (.*//')
                    echo "📱 Found fallback iPhone simulator: $SIMULATOR_NAME ($IPHONE_UUID)"
                    SIMULATOR_UUID=$IPHONE_UUID
                else
                    echo "❌ No iPhone simulators found!"
                    echo "Available simulators:"
                    xcrun simctl list devices | grep -E "iPhone|iPad"
                    exit 1
                fi
            fi
        fi
    fi

    return 0
}

# Shutdown any running simulators first
echo "🔄 Shutting down any running simulators..."
xcrun simctl shutdown all

# Find and set simulator UUID
find_and_boot_simulator

# Boot the selected simulator
echo "📱 Booting $SIMULATOR_NAME simulator..."
xcrun simctl boot $SIMULATOR_UUID

# Open Simulator app
echo "📱 Opening Simulator app..."
open -a Simulator

# Wait for simulator to fully boot and be detected by Flutter
echo "⏳ Waiting for simulator to boot and be detected..."
sleep 5

# Only clean if build directory doesn't exist or if pubspec.yaml changed
if [ ! -d "build" ] || [ "pubspec.yaml" -nt "build" ] || [ ".env" -nt "build" ]; then
    echo "🧹 Cleaning project..."
    flutter clean
    echo "📦 Getting dependencies..."
    flutter pub get
else
    echo "⚡ Skipping clean - using cached build"
fi

# Build and run the app
echo "🔨 Building and launching app on $SIMULATOR_NAME..."
flutter run -d "$SIMULATOR_NAME"
