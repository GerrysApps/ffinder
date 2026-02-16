Copyright (c) 2023-2025 GerrysApps.com  
My first flutter project. Download at [Gerry's Apps](https://gerrysapps.com)

### flutter setup
https://docs.flutter.dev/install/manual

# this setx doesn't seem to work, update PATH manually!!!!!!!!!!!
setx PATH "$($env:PATH);D:\flutter\bin"
setx PATH "$($env:PATH);D:\flutter\cmdline-tools\bin"

setx ANDROID_HOME "C:\Users\Gerry\AppData\Local\Android\Sdk"
setx ANDROID_SDK_ROOT "C:\Users\Gerry\AppData\Local\Android\Sdk"
setx PATH "$($env:PATH);C:\Users\Gerry\AppData\Local\Android\Sdk\platform-tools"
setx PATH "$($env:PATH);C:\Users\Gerry\AppData\Local\Android\Sdk\cmdline-tools\latest\bin"

flutter config --android-sdk "C:\Users\Gerry\AppData\Local\Android\Sdk"

flutter doctor

flutter pub get
flutter pub deps --json   # optional dependency info
flutter run -d windows    # run on Windows desktop


While you are correct that you'll be building for your Windows 11 machine, Flutter's build system specifically looks for the Windows 10 SDK (10.0.19041.0) headers to link correctly.

Essential Components to Check
Based on your uploaded image (image_b36482.png), select these exact boxes:

Windows SDK for Desktop C++ amd64 Apps: This is the most critical one for your 64-bit Windows machine.

Windows SDK for Desktop C++ x86 Apps: Flutter often requires these headers for broad compatibility even if your primary target is 64-bit.

Windows SDK Signing Tools for Desktop Apps: You will eventually need these to sign your MyEzInbox or OwlMail Windows executables for distribution.


# stop complaining about Chrome
flutter config --no-enable-web

### other notes for me below

Must enable Developer mode (in Settings) for Windows to be able to use the path_provider (or some "plugin")
    Go to Settings (Win + I).
    Search for "Developer settings".
    Toggle "Developer Mode" to "On".

run 'flutter clean' lots 

flutter upgrade
flutter build windows --release
files are here: .\ffinder\build\windows\x64\runner\Release

[Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/)

flutter pub deps --json
flutter pub get

### if moving the project to another folder:
Delete the build folder in your project directory
flutter clean
flutter create .
flutter run

#### video file types
mp4, mkv, m4v, avi, iso, m4a