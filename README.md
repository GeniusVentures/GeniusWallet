# Genius Wallet

A Cryptocurrency wallet app built with [Flutter](https://flutter.dev/) and [Parabeac](https://parabeac.com/).

## Download Genius Wallet project

```bash
git clone git@github.com:GeniusVentures/GeniusWallet.git --recursive 
cd GeniusWallet
```

## Setting up the environment

The flutter dependency is dealt with by downloading and building the thirdparty project.
 
[Build thirdparty project](../../../thirdparty/blob/master/README.md)

Simply add `thidparty/build/PLATFORM/Release` to `PATH`. 

## Run on Linux

```bash
    flutter run
```
You're going to be prompted a run option. For example:

```bash
    Connected devices:
    Linux (desktop) • linux  • linux-x64      • Linux Mint 21 5.15.0-41-generic
    Chrome (web)    • chrome • web-javascript • Google Chrome 114.0.5735.198
    [1]: Linux (linux)
    [2]: Chrome (chrome)
    Please choose one (or "q" to quit): 1
```

## Resources
* [Figma File](https://www.figma.com/file/YFBxDHU58kCfKP5TiHXWsz/GNUS-Build?node-id=81%3A1121) 


## File Upload for Submitting a SGNUS Job
### Linux
- Must have Zenity installed - `sudo apt install zenity`

## Building Release/Debug/RelWithDebInfo
### \<ostype\> = linux, chrome, ios, android, macos, windows

### Release
``` 
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release" flutter build <ostype> --release
```

### Debug (default)
``` 
flutter build <ostype>
```
 - OR -

 ```  
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Debug" flutter build <ostype> --debug
```

### Release with Debug Info
``` 
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=RelWithDebInfo -DSANITIZE_CODE=address" flutter -v build <ostype> --profile
```

<BR>
<BR>
<BR>


# 🚀 Sandbox Mode

The wallet supports **Sandbox Mode**, allowing it to run **without third-party dependencies**. This is useful for testing and development without requiring external services.


## 🛠️ Enabling Sandbox Mode

To enable **Sandbox Mode**, set `CMAKE_SKIP_THIRD_PARTY` to `ON` in the `CommonOverrideFlags.cmake` file:

```cmake
set(CMAKE_SKIP_THIRD_PARTY ON)
```

This ensures that third-party dependencies are skipped when building the wallet.


## 🔑 Passing a Wallet Private Key

You can provide a **wallet private key** during startup via **Flutter arguments** or a **launch file**.

### 📌 **Option 1: Using Flutter Arguments**
Run the following command to start the wallet with an imported private key:
```sh
flutter run -d windows --dart-define=WALLET_PK=yourprivatekey
```

### 📌 **Option 2: Using a Launch File**
To set the private key in a **launch file**, add the following configuration:

```json
"args": [
    "--dart-define=WALLET_PK=yourprivatekey"
],
```

This approach allows you to predefine the wallet key for easier debugging and testing.

---

### 🎯 Summary

| Feature             | Description |
|--------------------|------------|
| **Sandbox Mode**   | Runs without third-party dependencies |
| **CMake Setting**  | `set(CMAKE_SKIP_THIRD_PARTY ON)` |
| **Private Key Input** | Pass via Flutter args or a launch file |

---

