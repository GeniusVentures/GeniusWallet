# Genius Wallet

A Cryptocurrency wallet app built with [Flutter](https://flutter.dev/) and [Parabeac](https://parabeac.com/).

## Quick start

### Build on Linux and Android on Linux

### Install the prerequisites
        
        sudo apt-get update
        sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk wget default-jdk
        sudo apt-get clean

### Install Flutter from thirdparty directory, it should be one level up from GeniusWallet

       pushd ../thirdparty
       # save flutter path for later.
       echo "export PATH=\"\$PATH:`pwd`/flutter/bin\"" >>~/.bash_profile
       export PATH="$PATH:`pwd`/flutter/bin"
       popd
       flutter channel stable

#### Check if flutter is working.
        flutter doctor
        
#### Android ONLY - Check android sdk is present or not
        flutter sdk-path

### Install Android SDK if required

#### Download the Android SDK

        cd /opt
        sudo wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O android-sdk.zip
        sudo unzip -q android-sdk.zip -d android-sdk-linux
        sudo rm android-sdk.zip

#### Set up the environment variables (add to bashrc or bash_profile)

        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
        export ANDROID_HOME=/opt/android-sdk-linux
        export PATH=$ANDROID_HOME/platform-tools:$ANDROID_HOME/latest/bin:$PATH

#### Set appropriate file/directory permissions and Accept the licenses

        sudo chown -R pitzlabs:pitzlabs android-sdk-linux/
        sudo chmod -R 755 android-sdk-linux/
        sdkmanager --licenses

#### Install the SDK tools (before installation, you can find the available versions)

        sdkmanager "platform-tools" "platforms;android-33"
        sdkmanager "build-tools;33.0.0" 

#### verify the installation and accept any missing licenses.
        
        flutter doctor
        flutter doctor --android-licenses

### Change to the genius wallet root directory and build the application

        cd <path to genius wallet>
        flutter pub get
        flutter build apk -OR- flutter build linux


## Resources
* [Figma File](https://www.figma.com/file/YFBxDHU58kCfKP5TiHXWsz/GNUS-Build?node-id=81%3A1121) 
