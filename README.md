<p align="center">
  <img src="assets/icons/icon.png" alt="Readium" width="120" height="120">
</p>

<h1 align="center">Readium</h1>

<p align="center">
  <strong>Read Medium articles for free. No subscription required.</strong>
</p>

<p align="center">
  <a href="https://github.com/Alok-Sci/readium"><img src="https://img.shields.io/github/stars/Alok-Sci/readium?style=flat&label=stars&labelColor=0F172A&color=8B5CF6&logo=github&logoColor=fff" alt="github"></a>
  <a href="https://opensource.org/licenses/GPL-3.0"><img src="https://img.shields.io/badge/License-GPL%20v3-22C55E.svg?labelColor=0F172A&style=flat" alt="license"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=fff&labelColor=0F172A" alt="flutter"></a>
  <a href="https://github.com/Alok-Sci/readium"><img src="https://img.shields.io/github/contributors/Alok-Sci/readium?logo=github&logoColor=fff&labelColor=0F172A&color=F59E0B&style=flat" alt="contributors"></a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#installation">Installation</a> •
  <a href="https://github.com/Alok-Sci/readium/issues">Issues</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## Features

- 📖 **Free Access** – Read Medium member-only articles without subscription
- 🎨 **Medium-like UI** – Familiar typography and clean design
- 🌓 **Dark/Light Theme** – Comfortable reading in any lighting
- 💾 **Reading History** – Track articles you've read
- 🔗 **Deep Linking** – Share articles seamlessly
- ⚙️ **Customizable** – Adjust font size and appearance
- 💻 **Code Highlighting** – Beautiful syntax highlighting for code blocks
- 📱 **Cross-platform** – Available on Android and iOS

## Getting Started

### For Users

1. Download the app from Google Play Store or App Store
2. Paste any Medium article URL
3. Read for free – even member-only articles!
4. Share with friends using Readium

### For Developers

#### Prerequisites

- Flutter SDK (>=3.6.0)
- Dart SDK (>=3.6.0)
- Android Studio / VS Code
- Xcode (for iOS)

#### Installation

```bash
# Clone the repository
git clone https://github.com/Alok-Sci/readium.git
cd readium

# Install dependencies
flutter pub get

# Run the app
flutter run
```

#### Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Architecture

```
lib/
├── core/              # Core functionality
│   ├── config/       # App configuration
│   ├── services/     # Business logic
│   └── theme/        # UI theming
├── features/         # Feature modules
│   ├── article/      # Article reading
│   ├── history/      # Reading history
│   ├── home/         # Home screen
│   └── settings/     # App settings
└── main.dart         # Entry point
```

### Tech Stack

- **Flutter** – UI framework
- **Dart** – Programming language
- **SQLite** – Local storage
- **Freedium API** – Article fetching service

## Deep Linking

Readium supports:
- **Custom scheme**: `readium://medium.com/article-path`
- **Medium URLs**: Direct handling of `medium.com` and `*.medium.com` URLs
- **Share intent**: Share Medium articles directly to Readium

## Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Freedium** – For providing the API service ([freedium.cfd](https://freedium.cfd))
- **Flutter team** – For the amazing framework
- **Open source community** – For incredible packages and tools

## Support

- **Issues**: [GitHub Issues](https://github.com/Alok-Sci/readium/issues)
- **Email**: devreadium@gmail.com

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/Alok-Sci">Alok Singh</a>
</p>

<p align="center">
  <a href="https://github.com/Alok-Sci/readium">⭐ Star us on GitHub</a> •
  <a href="https://github.com/Alok-Sci/readium/issues">🐛 Report Bug</a> •
  <a href="https://github.com/Alok-Sci/readium/discussions">💡 Request Feature</a>
</p>
