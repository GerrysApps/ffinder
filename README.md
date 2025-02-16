Copyright (c) 2023-2025 GerrysApps.com  

My first (and only) flutter project.

Must enable Developer mode (in Settings) for Windows to be able to use the path_provider (or some "plugin")
    Go to Settings (Win + I).
    Search for "Developer settings".
    Toggle "Developer Mode" to "On".

run 'flutter clean' lots 

# if moving the project:
Delete the build folder in your project directory
flutter clean
flutter create .
flutter run

flutter build windows --release
files are here: .\ffinder\build\windows\x64\runner\Release

[Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/)

flutter pub deps --json
flutter pub get