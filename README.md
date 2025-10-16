# Color Studio - Flutter Color Picker for Windows

A powerful tool to pick colors from anywhere on your Windows screen and display the color code in various Flutter formats.

## ✨ Features

- 🎨 **Screen Color Picker** - Pick colors from any point on your Windows screen


<img width="600"  alt="Capturecsdxs" src="https://github.com/user-attachments/assets/b7872ba4-8758-4e09-8168-e429222da568" />




https://github.com/user-attachments/assets/b9eb8127-ec0c-4313-8371-ad27d46b3001





- 📋 **Quick Copy** - Copy color codes with a single click
- 🎯 **Multiple Flutter Formats**:
  - HEX (`#RRGGBB`)
  - Color (`Color(0xFFRRGGBB)`)
  - Color.fromARGB
  - Color.fromRGBO
  - RGB
  - RGBA
  - HSL
  - Integer Value

- 🖥️ **Modern UI** - Beautiful Material Design 3 interface
- 🌓 **Dark/Light Theme Support**

## 🚀 How to Run

### Prerequisites

- Flutter SDK
- Windows 10 or higher

### Installation Commands

```bash
# Install dependencies
flutter pub get

# Run the application
flutter run -d windows

# Build executable
flutter build windows
```

## 📦 Packages Used

- **screen_capturer** - For screen capture and color picking
- **clipboard** - For copying to clipboard
- **flutter_colorpicker** - For color selection and management

## 🎯 How to Use

### Color Picking with Eyedropper:
1. Launch the application
2. Click the **"Pick Color from Screen"** button
3. A full-screen overlay with precise cursor will appear
4. Move your mouse over any color on the screen:
   - 🔍 A **magnifier** appears next to the cursor
   - 🎨 The color under cursor is displayed **instantly**
   - 📋 HEX color code is shown at the top of the screen
5. **Left-click** to select the desired color
6. **Right-click** to cancel
7. The selected color and its codes in all formats will be displayed
8. Click the **copy** icon next to any format

### Usage Examples:
- ✅ Pick colors from desktop icons
- ✅ Pick colors from images in browser
- ✅ Pick colors from other applications
- ✅ Pick colors from anywhere in Windows system

## 🎨 UI Features

- **Real-time Preview** - See the selected color in a large preview box
- **Multiple Color Formats** - Get color codes in all popular Flutter formats
- **One-click Copy** - Copy any format with a single click
- **Responsive Design** - Works on different screen sizes
- **Persian/English Support** - Bilingual interface

## 📝 Developer

Built with ❤️ using Flutter

## 📄 License

This project is released under the MIT License.

## 🔧 Technical Details

- **Platform**: Windows (Flutter Windows Desktop)
- **Framework**: Flutter 3.x
- **Architecture**: Material Design 3
- **State Management**: Built-in Flutter State
- **Color Picking**: Native Windows screen capture API

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 📞 Support

If you encounter any issues or have questions, please open an issue on the repository.

---

**Happy Color Picking! 🎨**

---

## What's New in v2 compared to v1

- No startup white flicker: saved theme is read before `runApp` and set as `initialThemeMode`.
- Immediate loading of saved language: read from storage and set as `initialLocale` in `GetMaterialApp`.
- Build-phase safety: avoid calling `Get.updateLocale` or `Get.changeThemeMode` during build to prevent `setState() or markNeedsBuild() called during build` errors.
- Translations integration: add `AppTranslations` and key maps for `en_US` and `fa_IR`, use `.tr` in widgets.
- Simplified app bootstrap in `main.dart`: pass `initialThemeMode` and `initialLocale` directly to `GetMaterialApp` for a flicker-free startup.
- Theme management: change theme via `ThemeController` methods `setLight`, `setDark`, and `setSystem`; `onInit` only reads the stored value.
- Language management: change language via `LanguageController.changeLanguage`; `onInit` only loads the persisted value.

### Upgrade Guide from v1
- If controllers changed theme/locale directly in `onInit`, move that logic to `main.dart` so it runs before `runApp`.
- Ensure `GetMaterialApp` is wired with `translations`, `initialLocale`, and `locale`.
- For UI language switching, use `LanguageController.changeLanguage('fa_IR' | 'en_US')` only.

### How to Test
- Switch language to Persian and restart: UI loads in Persian immediately.
- Switch theme to dark and restart: dark theme loads with no white flicker.
