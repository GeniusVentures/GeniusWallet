# Genius Wallet - Release Usage Instructions

## Supported Platforms

* **Windows** (`Windows-Release.zip`)
* **Linux (x86\_64)** (`Linux-x86_64-Release.tar.gz`)
* **Linux (aarch64)** (`Linux-aarch64-Release.tar.gz`)
* **Android** (`Android-Release.apk`)
* **iOS and macOS** (distributed via TestFlight, contact us for access)

---

## Windows

1. Download `Windows-Release.zip` from the GitHub release page.
2. Extract the zip file.
3. Inside the extracted folder, you will find `genius_wallet.exe`.
4. Double-click `genius_wallet.exe` to launch Genius Wallet on Windows.

---

## Linux (x86\_64 and aarch64)

1. Download the appropriate tar.gz for your architecture:

   * `Linux-x86_64-Release.tar.gz` for x86\_64
   * `Linux-aarch64-Release.tar.gz` for aarch64 (ARM64)
2. Extract using:

   ```bash
   tar -xvf Linux-x86_64-Release.tar.gz
   # or
   tar -xvf Linux-aarch64-Release.tar.gz
   ```
3. Navigate to the extracted directory:

   ```bash
   cd artifacts/bundle
   ```
4. Run the app:

   ```bash
   ./genius_wallet
   ```

   If you get a "Permission denied" error:

   ```bash
   chmod +x genius_wallet
   ./genius_wallet
   ```

---

## Android

1. Download `Android-Release.apk` from the GitHub release page.
2. Transfer the APK to your Android device.
3. **Enable installation from unknown sources:**

   * Open **Settings**.
   * Go to **Security** or **Apps & notifications** (varies by device).
   * Tap **Install unknown apps** or **Special app access**.
   * Select your browser or file manager.
   * Enable **Allow from this source**.
4. Locate the APK in your downloads or file manager.
5. Tap it and follow the installation prompts.
6. Open **Genius Wallet** from your app drawer.
7. (Optional) You can disable **Allow from this source** afterward.

---

## iOS and macOS

Distributed via **TestFlight**.

Contact us to request TestFlight access, and we will send you an invitation link to join the Genius Wallet beta.

---

## Feedback and Support

If you encounter issues, please open an issue on GitHub or contact us directly for support.

Thank you for using Genius Wallet!
