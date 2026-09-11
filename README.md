# 📻 Falah Radio - راديو فلاح

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-blue.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)]()
[![Developer](https://img.shields.io/badge/Developer-Falah.G.Salieh%202025%20Co-purple.svg)]()

> **Falah Radio (راديو فلاح)** is a world-class global radio streaming and audio recording application built with Flutter. Connecting listeners to over **58,000+ live broadcast stations** across **240+ nations and territories**, with instant search, multi-codec playback (MP3, AAC+, OGG, FLAC), timed live MP3 recording directly to device storage, offline playback, and bilingual English/Arabic RTL experience.

---

## 🌟 Key Features

### 1. 📻 58,000+ Worldwide Stations Explorer
- Comprehensive directory powered by the community-driven **Radio-Browser API** with automatic mirror failover (`de1.api.radio-browser.info`).
- **Country Catalogs**: Grouped by regions (Arab World & Middle East 🕌, Europe 🏰, Americas 🌎, Asia 🏯, and All Nations 🌍) with national flag emojis.
- **Top Channels & Genres**: Most listened worldwide, community top-rated, and genre filters (News, Quran, Jazz, Classical, Rock, Pop, Chillout).
- **Advanced Filtering**: Filter by broadcast codec (MP3, AAC+, OGG), minimum bitrate (64k, 128k, 192k, 320k), language, and country code.

### 2. 🎙️ Live Stream MP3 Recording to Device Downloads
- Direct HTTP stream capture saving genuine MP3 audio files to your real device storage:
  - Android download directory: `/storage/emulated/0/Download/RadioRecordings/`
- Preset timers: **30 seconds (Quick Clip)**, **1 minute (Standard)**, **3 minutes (Song Track)**, **5 minutes (Segment)**, or manual continuous recording.
- Real-time recording indicator with elapsed duration badge.
- Fully compatible with Android 10, 11, 12, 13, and 14 scoped storage and runtime permissions.

### 3. ❤️ Favorites & Offline Listening History
- One-tap heart bookmarking to pin favorite stations for instant tuning.
- Automatic playback history tracking recently listened channels.
- Offline playback engine in the **Downloads** tab to play captured MP3 tracks anytime without internet connection.

### 4. 👤 User Profile & Local State Caching
- User profile system with Sign-In and Sign-Out modal workflows.
- Cached locally via `SharedPreferences`: stores user display name, registration timestamp, and authentication state.
- Interactive side drawer avatar with quick user identity management.

### 5. 🌓 Cyber Dark & Clean Light Themes
- **Cyber Dark Mode**: Deep slate `#090D16` with neon cyan `#00E5FF` and electric purple `#8B5CF6` accents.
- **Clean Light Mode**: High-contrast, crisp typography designed for maximum daylight readability.
- Instant toggle from the home header and side drawer with zero latency.

### 6. 🌐 Instant English / Arabic (العربية) Translation
- Native **RTL (Right-to-Left)** layout adaptation for Arabic users.
- Live language toggle switch across all dialogs, bottom sheets, navigation menus, and screens without restarting the app.

### 7. 📄 Help Documentation & Developer Showcase
- **Help Documentation (`HelpScreen`)**: In-app guide explaining stream search, recording mechanics, favorites, and technical audio specs.
- **Developer Profile (`DeveloperProfileScreen`)**: Official developer showcase honoring **Iraqi Developer Falah.G.Salieh 2025 Co.** with contact options and tech stack details.

---

## 📱 Application Screens & Navigation

The app is architected with a persistent 5-tab `NavigationBar` plus a floating `MiniPlayerBar`:

1. **Home (`HomeScreen`)**: Hero live banners, top worldwide stations, regional quick-access pills, and side drawer hamburger menu.
2. **Countries (`CountriesScreen`)**: 240+ countries organized into geographic tabs with real-time station counts.
3. **Search & Filters (`SearchScreen`)**: Real-time keyword search with custom bottom sheet for codec and bitrate filtering.
4. **Favorites (`FavoritesScreen`)**: Bookmarked stations and recent listening history.
5. **Downloads (`DownloadsScreen`)**: Saved MP3 recordings stored locally on the device with in-app audio playback.
6. **Player Screen (`PlayerScreen`)**: Full-screen player with live bitrate/codec stats, stream URL copier, and MP3 recording dialog.
7. **Side Drawer (`AppDrawer`)**: User profile card, main navigation shortcuts, Help Documentation, Developer Profile, and quick toggles.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Framework** | Flutter 3.x (Material 3 with custom Design System) |
| **Language** | Dart 3.x (Null safety enabled) |
| **State Management** | `Provider` & `ChangeNotifierProxyProvider` |
| **Audio Engine** | `audioplayers` 6.7.1 (Live HTTP stream buffering) |
| **Networking** | `http` 1.6.0 with mirror failover and timeout resilience |
| **Local Storage** | `shared_preferences` (Favorites, recents, theme, locale, user profile) |
| **File I/O & Permissions** | `path_provider` & `permission_handler` |
| **Typography** | Google Fonts (`Outfit`) & Arabic typography |

---

## 📦 Building & Deployment

### 1. Build Production Android App Bundle (.aab)
Signed using JDK's `keytool` and configured in `android/app/build.gradle.kts`:
```bash
flutter build appbundle --release
```
- Output: `build/app/outputs/bundle/release/app-release.aab` (Google Play ready)

### 2. Build Production Release APK
```bash
flutter build apk --release
```
- Output: `build/app/outputs/flutter-apk/app-release.apk` (55.6 MB, signed with release keystore)

### 3. Run Automated Tests & Static Analysis
```bash
dart analyze lib/
flutter test
```

---

## 🚀 Repository & Remote

- **GitHub Remote**: `git@github.com:Eman2024956/radio_channel.git`
- **Branch**: `main`

To pull the latest changes:
```bash
git clone git@github.com:Eman2024956/radio_channel.git
cd radio_channel
flutter pub get
flutter run
```

---

## ⚖️ Copyright & Credits

```
COPYRIGHT BY Iraqi Developer Falah.G.Salieh 2025 co.
All Rights Reserved.
```

- **Developer**: Falah Gatea Salieh (العراق - بغداد 🇮🇶)
- **Company**: Falah.G.Salieh 2025 Co.
- **API Attribution**: Powered by [Radio-Browser.info](https://www.radio-browser.info/) community open database.
