# How to Change App Icon/Logo for APK

## 📱 Method 1: Using flutter_launcher_icons (RECOMMENDED - Easiest)

This is the easiest and most automated way to change your app icon.

### Step 1: Prepare Your Icon Image

Create a **1024x1024 PNG** image with your logo:
- **Format**: PNG with transparency (recommended) or solid background
- **Size**: 1024x1024 pixels minimum
- **Name**: `app_icon.png` (or any name you prefer)
- **Location**: Save it in your project root or in `lib/assets/images/`

**Example using your existing logo:**
```
c:\Users\MYPC\Documents\EcoSustain\Eco-Sustain-Flutter-App\lib\assets\images\logo.png
```

### Step 2: Add flutter_launcher_icons Package

Open `pubspec.yaml` and add to **dev_dependencies**:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.1  # ← Add this
```

### Step 3: Configure Icon Settings

Add this configuration at the **bottom** of `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false  # Set to true if you want iOS icons too
  image_path: "lib/assets/images/logo.png"  # Path to your icon
  adaptive_icon_background: "#2ECC71"  # Your app's green color
  adaptive_icon_foreground: "lib/assets/images/logo.png"
```

### Step 4: Install and Generate Icons

Run these commands in PowerShell:

```powershell
# Install dependencies
flutter pub get

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

### Step 5: Rebuild APK

```powershell
flutter clean
flutter build apk --release
```

**Done!** Your new icon will appear in the APK.

---

## 🎨 Method 2: Manual Icon Replacement (Advanced)

If you prefer to do it manually or need more control:

### Android Icon Sizes Required

You need to create **5 different sizes** of your icon:

| Folder | Size | Resolution |
|--------|------|------------|
| `mipmap-mdpi` | 48x48 px | ~160 dpi |
| `mipmap-hdpi` | 72x72 px | ~240 dpi |
| `mipmap-xhdpi` | 96x96 px | ~320 dpi |
| `mipmap-xxhdpi` | 144x144 px | ~480 dpi |
| `mipmap-xxxhdpi` | 192x192 px | ~640 dpi |

### Manual Replacement Steps

1. **Create all 5 icon sizes** using an image editor (Photoshop, GIMP, Figma, Canva)

2. **Replace these files** with your icons:
   ```
   android/app/src/main/res/mipmap-mdpi/ic_launcher.png
   android/app/src/main/res/mipmap-hdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
   ```

3. **Rebuild the APK**:
   ```powershell
   flutter clean
   flutter build apk --release
   ```

---

## 🌐 Online Tools to Generate Icons

If you don't want to manually resize, use these free tools:

### Option A: AppIcon.co (Recommended)
1. Go to https://www.appicon.co/
2. Upload your 1024x1024 PNG
3. Select "Android" only
4. Download the generated files
5. Replace files in `android/app/src/main/res/mipmap-*` folders

### Option B: Android Asset Studio
1. Go to https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
2. Upload your icon
3. Adjust settings (padding, background color)
4. Download ZIP file
5. Extract and replace files in `android/app/src/main/res/`

---

## 🎯 Quick Start: Change Icon Now

Since you already have `logo.png`, here's the fastest way:

### Step 1: Update pubspec.yaml

Add this to your `pubspec.yaml`:

```yaml
# At the end of the file
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "lib/assets/images/logo.png"
  adaptive_icon_background: "#2ECC71"
  adaptive_icon_foreground: "lib/assets/images/logo.png"
```

And add to dev_dependencies:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.1
```

### Step 2: Run Commands

```powershell
flutter pub get
flutter pub run flutter_launcher_icons
flutter clean
flutter build apk --release
```

### Step 3: Find Your APK

```
build/app/outputs/flutter-apk/app-release.apk
```

Install it on your device and see your new icon! 🎉

---

## 📋 Icon Design Best Practices

### Do's ✅
- Use **1024x1024 minimum** resolution for source image
- Use **simple, recognizable designs**
- Test on both light and dark backgrounds
- Use **PNG format** with transparency
- Keep **important elements centered** (outer 10% may be cropped)
- Use **high contrast** colors

### Don'ts ❌
- Don't use text-heavy designs (hard to read at small sizes)
- Don't use gradients excessively (may not scale well)
- Don't rely on fine details (will be lost at small sizes)
- Don't use photos (icons should be symbolic)

---

## 🔍 Verify Your Icon

After building, verify your icon appears correctly:

1. **Install APK** on Android device
2. **Check home screen** - Icon should appear
3. **Check app drawer** - Icon should appear
4. **Check recent apps** - Icon should appear

---

## 🎨 EcoSustain Icon Recommendations

Based on your app theme (green, eco-friendly):

### Option 1: Simple Leaf Icon
- Green leaf symbol on white/transparent background
- Matches your #2ECC71 brand color

### Option 2: Recycling Symbol
- Modern recycling arrows
- Green color with white background

### Option 3: Logo from Existing Asset
- Use your current `logo.png`
- Make sure it's high resolution (1024x1024+)

---

## 🐛 Troubleshooting

### Icon not updating after rebuild?
```powershell
flutter clean
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### Icons look pixelated?
- Use higher resolution source image (1024x1024 minimum)
- Ensure PNG format, not JPEG

### Only seeing default Flutter icon?
- Check file paths in `flutter_launcher_icons` config
- Run `flutter pub run flutter_launcher_icons` again
- Verify files exist in `android/app/src/main/res/mipmap-*` folders

---

## 📚 Additional Resources

- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Icon Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [Material Design Icons](https://fonts.google.com/icons)

---

**Next Step:** Choose Method 1 (automated) and run the commands to change your icon! 🚀
