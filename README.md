# Genius Wallet

A Cryptocurrency wallet app built with [Flutter](https://flutter.dev/) and [Parabeac](https://parabeac.com/).

## Download Genius Wallet project

```bash
git clone git@github.com:GeniusVentures/GeniusWallet.git --recursive 
cd GeniusWallet
```

### Installing Flutter

The project requires Flutter version 3.32.5 or higher.

<details>
<summary><strong>Expanded Flutter installation instructions</strong></summary>

We provide installation scripts that will automatically install Flutter in the `../thirdparty/flutter` directory if needed.

#### Automatic Installation (Recommended)

**Linux/macOS:**

```bash
./install_flutter.sh
```

**Windows:**

```cmd
install_flutter.bat
```

The scripts will:

* Check if Flutter is already installed and its version
* Install Flutter 3.32.5+ if needed via the thirdparty Git submodule
* Provide instructions for PATH configuration

#### Manual Installation

If you prefer manual installation or the scripts don't work:

```bash
pushd ..
git clone git@github.com:GeniusVentures/thirdparty.git
cd thirdparty
git checkout main
git pull
git submodule update --init --recursive -- flutter
# Add to PATH - Linux/macOS:
export PATH="${PWD}/flutter/bin:${PATH}"
# Add to PATH - Windows:
# set PATH=%CD%\flutter\bin;%PATH%
popd
```

After installation, add `thirdparty/flutter/bin` to your PATH permanently.

</details>

### Building Dependencies

The project uses CMake to automatically download required dependencies (SuperGenius, GeniusSDK, zkLLVM, thirdparty) when building. These are downloaded based on your platform and build type.

For manual dependency management, see [Build thirdparty project](../../../thirdparty/blob/master/README.md).

<details>
<summary><strong>iOS and macOS Development Setup</strong></summary>

## iOS and macOS Development Setup

For iOS and macOS development, you'll need to install CocoaPods:

**Recommended: Install via RVM (Ruby Version Manager)**

Using RVM allows you to manage multiple Ruby versions for different projects:

```bash
# Install RVM if you don't have it
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

# Install Ruby 3.2.4 (or check your current version with: rvm list)
rvm install 3.2.4
rvm use 3.2.4 --default

# IMPORTANT: Install CocoaPods for this Ruby version
gem install cocoapods

# Verify CocoaPods is installed in the right place
which pod  # Should show: ~/.rvm/gems/ruby-3.2.4/bin/pod
pod --version
```

**Fixing OpenSSL Errors when Installing Ruby**

If you get `make[1]: *** [ext/openssl/all] Error 2` when installing Ruby:

```bash
# For Apple Silicon Macs (M1/M2/M3)
brew install openssl@3
rvm install 3.2.4 --with-openssl-dir=$(brew --prefix openssl@3)

# For Intel Macs
brew install openssl@1.1
rvm install 3.2.4 --with-openssl-dir=$(brew --prefix openssl@1.1)

# Alternative: Use rbenv instead of RVM
brew install rbenv ruby-build
rbenv install 3.2.4
rbenv global 3.2.4
```

**Common Issue: "pod: command not found" with RVM**

If you have RVM Ruby but `pod` isn't found:

```bash
# 1. Make sure you're using the right Ruby
rvm use 3.2.4
which ruby  # Should show: ~/.rvm/rubies/ruby-3.2.4/bin/ruby

# 2. Install CocoaPods for THIS Ruby version
gem install cocoapods

# 3. Rehash to update available commands
rvm gemset rehash

# 4. Verify installation
gem list cocoapods  # Should show cocoapods in the list
which pod           # Should show: ~/.rvm/gems/ruby-3.2.4/bin/pod
```

**Making Flutter use RVM's Ruby instead of System Ruby**

Flutter may default to macOS system Ruby. To fix this:

1. **Ensure RVM is loaded in your shell:**

   ```bash
   # Add to ~/.bashrc or ~/.zshrc if not already there:
   source ~/.rvm/scripts/rvm
   ```

2. **Check which Ruby Flutter is using:**

   ```bash
   # In your Flutter project directory
   which ruby        # Should show ~/.rvm/rubies/ruby-3.2.4/bin/ruby
   ruby --version    # Should show ruby 3.2.4
   which pod         # Should show ~/.rvm/gems/ruby-3.2.4/bin/pod
   ```

3. **If Flutter still uses system Ruby, create a wrapper script:**

   ```bash
   # Create a pod wrapper that ensures RVM Ruby is used
   sudo mkdir -p /usr/local/bin
   sudo tee /usr/local/bin/pod > /dev/null << 'EOF'
   #!/bin/bash
   source ~/.rvm/scripts/rvm
   rvm use 3.2.4
   exec ~/.rvm/gems/ruby-3.2.4/bin/pod "$@"
   EOF
   sudo chmod +x /usr/local/bin/pod
   ```

4. **Alternative: Set Ruby version for the project:**

   ```bash
   # In your Flutter project root
   echo "3.2.4" > .ruby-version

   # This tells RVM to automatically switch to 3.2.4 when entering the directory
   ```

5. **Verify the fix:**

   ```bash
   cd ios  # or macos
   pod --version     # Should work without Ruby warnings
   flutter clean
   flutter pub get
   cd ios && pod install  # Should use RVM's Ruby
   ```

**Troubleshooting Ruby Conflicts**

If you see errors like "You have already activated X, but your Gemfile requires Y":

```bash
# Clean up and reinstall
rvm use 3.2.4
gem uninstall cocoapods -a
gem install cocoapods
cd ios && rm -rf Pods Podfile.lock
pod install
```

**Note:** The macOS system Ruby is outdated and missing components. Always use RVM or rbenv for development.

You'll also need Xcode Command Line Tools:

```bash
xcode-select --install
```

**Setting up Xcode Developer Credentials**

If you see "Failed to load credentials" or "missing Xcode-Token" errors:

1. **Sign out and back in to Xcode:**

   ```
   Xcode → Preferences → Accounts
   - Select your Apple ID (dev@geniusventures.io)
   - Click the "-" button to remove it
   - Click "+" → Apple ID → Sign in again
   - Enter your Apple ID and password (or use 2FA if enabled)
   ```

2. **If that doesn't work, clear Xcode's credentials cache:**

   ```bash
   # Close Xcode first
   # Delete stored credentials
   security delete-generic-password -s "Xcode-Token"
   security delete-generic-password -s "Xcode-AlternateDSID"

   # Clear Xcode's derived data
   rm -rf ~/Library/Developer/Xcode/DerivedData

   # Restart Xcode and sign in again
   ```

3. **For CI/CD or command line builds:**

   ```bash
   # Sign in via command line
   xcrun altool --list-apps --username "dev@geniusventures.io" --password "@keychain:AC_PASSWORD"

   # Or store credentials
   xcrun altool --store-password-in-keychain-item "AC_PASSWORD" -u "dev@geniusventures.io" -p "your-app-specific-password"
   ```

4. **Download certificates manually:**

   * Go to Xcode → Preferences → Accounts
   * Select your team
   * Click "Download Manual Profiles"

**Note:** If using 2FA, you may need to generate an app-specific password at [https://appleid.apple.com](https://appleid.apple.com)

---

</details>

## Build & Run Instructions

### 📝 Development with VS Code (Recommended)

**Install VS Code Extensions:**

1. Install [Visual Studio Code](https://code.visualstudio.com/)
2. Install the following required extensions:
   - **Flutter** (by Dart Code) - Provides Flutter support and debugging
   - **Dart** (by Dart Code) - Dart language support (usually installed automatically with Flutter extension)

**Running from VS Code:**

1. Open the project folder in VS Code:
   ```bash
   code .
   ```

2. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run:
   ```
   Flutter: Select Device
   ```
   Choose your target device (Windows, macOS, Linux, Android emulator, iOS simulator, etc.)

3. **Using the Debug Panel (Recommended):**
   - Press `F5` or go to the Debug panel (`Ctrl+Shift+D` / `Cmd+Shift+D`)
   - Select one of the preconfigured launch configurations:
     - **GeniusWallet** - Debug mode with TestNet-Phase-3.1 dependencies
     - **GeniusWallet (profile mode)** - Profile mode for performance testing
     - **GeniusWallet (release mode)** - Release mode for production builds
   - Click the green play button or press `F5`

4. **Using Command Palette:**
   - `Ctrl+Shift+P` / `Cmd+Shift+P`
   - Type: `Flutter: Run Flutter App`
   - Select your desired launch configuration

**VS Code Features:**
- **Hot Reload**: Save files (`Ctrl+S` / `Cmd+S`) to see changes instantly
- **Hot Restart**: `Ctrl+Shift+F5` / `Cmd+Shift+F5` to restart the app
- **Debug Console**: View logs and debug output
- **Breakpoints**: Click line numbers to set breakpoints for debugging
- **Widget Inspector**: Use `Ctrl+Shift+P` → "Flutter: Open Widget Inspector"

### 🐧 Build on Linux

Run the following script from the root directory:

```bash
./build.sh
```

### ▶️ Run on Linux

```bash
./run.sh
```

Make sure you have granted execute permissions if needed:

```bash
chmod +x build.sh run.sh
```

### 🪟 Build on Windows

```cmd
build.bat
```

### ▶️ Run on Windows

```cmd
run.bat
```

### 🍎 Build on macOS

```bash
./build.sh
```

### ▶️ Run on macOS

```bash
./run.sh
```

Make sure you have granted execute permissions if needed:

```bash
chmod +x build.sh run.sh
```

<details>
<summary><strong>File Upload for Submitting a SGNUS Job</strong></summary>

### Linux

* Must have Zenity installed - `sudo apt install zenity`

</details>

<details>
<summary><strong>Building Release/Debug/RelWithDebInfo</strong></summary>

### <ostype> = linux, chrome, ios, android, macos, windows

#### Release

```
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release" flutter build <ostype> --release
```

#### Debug (default)

```
flutter build <ostype>
```

* OR -

```
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Debug" flutter build <ostype> --debug
```

#### Release with Debug Info

```
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=RelWithDebInfo -DSANITIZE_CODE=address" flutter -v build <ostype> --profile
```

</details>

<details>
<summary><strong>Building macOS without Code Signing</strong></summary>

For local development and testing without an Apple Developer account:

**Disable signing in Xcode project:**

1. Open `macos/Runner.xcodeproj` in Xcode
2. Select the Runner project → Runner target
3. Go to "Signing & Capabilities" tab
4. Uncheck "Automatically manage signing"
5. Set "Signing Certificate" to "Sign to Run Locally"

Then build normally:

```bash
flutter build macos
```

**Note:** Apps built with local signing:

* Can only run on your local machine
* Cannot be distributed to other users
* Cannot be notarized or uploaded to the App Store
* May trigger Gatekeeper warnings

</details>

<details>
<summary><strong>Controlling Dependency Downloads</strong></summary>

You can control how dependencies are downloaded:

```bash
# Skip all dependency downloads
CMAKE_ARGUMENTS="-DGENIUS_SKIP_DEPENDENCY_DOWNLOAD=ON" flutter build <ostype>

# Use a specific branch for dependencies
CMAKE_ARGUMENTS="-DGENIUS_DEPENDENCY_BRANCH=master" flutter build <ostype>
```

</details>

<details>
<summary><strong>🚀 Sandbox Mode</strong></summary>

The wallet supports **Sandbox Mode**, allowing it to run **without third-party dependencies**. This is useful for testing and development without requiring external services.

### 🛠️ Enabling Sandbox Mode

To enable **Sandbox Mode**, set `CMAKE_SKIP_THIRD_PARTY` to `ON` in the `CommonOverrideFlags.cmake` file:

```cmake
set(CMAKE_SKIP_THIRD_PARTY ON)
```

This ensures that third-party dependencies are skipped when building the wallet.

### 🔑 Passing a Wallet Private Key

You can provide a **wallet private key** during startup via **Flutter arguments** or a **launch file**.

#### 📌 Option 1: Using Flutter Arguments

```sh
flutter run -d windows --dart-define=WALLET_PK=yourprivatekey
```

#### 📌 Option 2: Using a Launch File

To set the private key in a **launch file**, add the following configuration:

```json
"args": [
    "--dart-define=WALLET_PK=yourprivatekey"
],
```

This approach allows you to predefine the wallet key for easier debugging and testing.

</details>

### 🎯 Summary

| Feature               | Description                                                               |
| --------------------- | ------------------------------------------------------------------------- |
| **Flutter Version**   | 3.32.5 or higher required                                                 |
| **Auto Install**      | Use `install_flutter.sh` (Linux/macOS) or `install_flutter.bat` (Windows) |
| **VS Code Setup**     | Install Flutter and Dart extensions, use F5 to run with preconfigured launches |
| **iOS/macOS Dev**     | Requires CocoaPods and Xcode Command Line Tools                           |
| **Dependencies**      | Automatically downloaded via CMake based on platform/build type           |
| **Sandbox Mode**      | Runs without third-party dependencies                                     |
| **CMake Setting**     | `set(CMAKE_SKIP_THIRD_PARTY ON)`                                          |
| **Private Key Input** | Pass via Flutter args or a launch file                                    |

---
