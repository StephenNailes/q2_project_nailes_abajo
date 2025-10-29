# EcoSustain Flutter App - AI Coding Agent Instructions

## Project Overview
EcoSustain (TechSustain) is a Flutter mobile app for e-waste recycling management. Users can submit electronics for recycling through a multi-step workflow, track their recycling history, access eco tips, and manage their profile.

## Architecture & Navigation

### Router Pattern
- Uses `go_router` (v16.2.1) for declarative navigation
- Central router: `lib/routes/app_router.dart` 
- All route changes use `context.go('/path')` or `context.push('/path')`
- Initial route: `/login` (see `appRouter` configuration)

### Screen Organization
```
lib/
  ├── auth/           # Login & registration (no auth integration yet)
  ├── screen/         # Main app screens (dashboard, profile, settings, etc.)
  ├── components/     # Feature-specific components grouped by feature
  │   ├── dashboard/
  │   ├── submission/  # 5-step submission flow components
  │   ├── ecotips/
  │   └── eco_bottom_nav.dart  # Shared bottom nav
  └── routes/         # Router configuration
```

### Component Hierarchy Pattern
- **Screens** (`screen/`) are top-level views with navigation bars
- **Components** (`components/`) are feature-specific reusable widgets
- Components are grouped by feature (e.g., `submission/`, `dashboard/`)
- Shared components like `EcoBottomNavBar` live at `components/` root

## Multi-Step Submission Workflow

**Critical Pattern**: The submission flow uses a 5-step wizard with dedicated components:

1. **Step1Select** - Choose item type (phone, charger, laptop)
2. **Step2Quantity** - Select quantity with +/- controls
3. **Step3DropOff** - Choose drop-off location
4. **Step4Photo** - Capture/upload device photos
5. **Step5Submit** - Review and confirm submission

**Navigation**: Uses `Navigator.push()` between steps (not go_router), allowing back navigation through the wizard. Entry point is `SubmissionScreen` → `Step1Select`.

**Progress Indicator**: All steps use `StepperHeader(currentStep: N)` component showing progress (1-5) with visual indicators.

## Design System

### Color Palette
- **Primary Green**: `Color(0xFF2ECC71)` - eco theme, active states, CTAs
- **Gradient Background**: `LinearGradient([Color(0xFFE9FBEF), Color(0xFFD6F5E0)])` - used on main screens
- **Card Background**: `Colors.white` with soft shadows
- **Text**: `Colors.black87` (primary), `Colors.black54` (secondary), `Colors.black45` (tertiary)

### UI Patterns
- **Cards**: White background, `borderRadius: 16`, subtle shadow (`Colors.black12`, `blurRadius: 8`)
- **Buttons**: Rounded (`borderRadius: 16`), primary green, white text, no elevation
- **Icon Containers**: Colored background with 12% opacity, matching icon color
- **Bottom Nav**: Fixed 5 items (Home, Tips, [FAB], Guides, Profile) with green active indicators

### Common Widget Styles
```dart
// Standard elevated button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2ECC71),
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
)

// Card container pattern
Container(
  padding: const EdgeInsets.all(16-18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
  ),
)
```

## Navigation Structure

### Bottom Navigation (currentIndex mapping)
- 0: `/home` (Dashboard)
- 1: `/tips` (Eco Tips)
- 2: `/guides` (Learning Hub)
- 3: `/submissions` (via FAB - FloatingActionButton)
- 4: `/profile` (Profile)

**Implementation**: `EcoBottomNavBar(currentIndex: N)` + `SubmissionButton()` as FAB

### Settings Sub-Navigation
Settings screen has child routes:
- `/settings/edit-profile`
- `/settings/change-password`
- `/settings/manage-email`

## Asset Management

### Images
All assets in `lib/assets/images/` with explicit path references:
```dart
Image.asset('lib/assets/images/logo.png')
CircleAvatar(backgroundImage: AssetImage("lib/assets/images/kert.jpg"))
```

**Available assets**: logo.png, Google__G__logo.png, kert.jpg, phone.png, ewaste.png, recycle.png, plus device images (macbook.jpg, ipad.jpg, apple-ip.jpg, charger.jpg, headphones.jpg)

### Icons
- Primary: Material Icons (`Icons.xxx`)
- Secondary: Lucide Icons (`lucide_icons: ^0.257.0`)
- Social: Font Awesome (`font_awesome_flutter: ^10.7.0`)

## State Management & Backend

**No state management library** - Currently using `StatefulWidget` for local state only.

**No backend integration** - All data is hardcoded:
- User info: "Kert Abajo", "kert.abajo@email.com"
- Recycled items count: "16"
- TODO markers indicate pending backend integration points

## Key Dependencies
```yaml
go_router: ^16.2.1          # Routing
lucide_icons: ^0.257.0      # Icon library
font_awesome_flutter: ^10.7.0
image_picker: ^1.0.7        # Image capture/upload
```

## Development Patterns

### When adding new screens:
1. Create screen file in `lib/screen/`
2. Add route to `lib/routes/app_router.dart`
3. If using bottom nav, add `EcoBottomNavBar(currentIndex: N)` and `SubmissionButton()` FAB
4. Apply gradient background container pattern if main screen

### When adding new components:
1. Group by feature in `lib/components/<feature>/`
2. Extract to `components/` root only if truly shared across features
3. Follow naming: `<feature>_<component>.dart` (e.g., `eco_tip_card.dart`)

### When implementing forms:
- Use `TextField` with consistent decoration (rounded corners, icons, white fill)
- Validation is currently minimal (TODOs exist for API integration)
- Password fields use `obscureText: true` with visibility toggle icon

### Image picker usage:
Import: `import 'package:image_picker/image_picker.dart';`
Used in Step4Photo for device photo capture

## Common Pitfalls

❌ **Don't** use `Navigator.push()` for main app navigation (use `context.go()`)  
✅ **Do** use `Navigator.push()` within multi-step flows (submission wizard)

❌ **Don't** hardcode colors - use the established palette  
✅ **Do** reference `Color(0xFF2ECC71)` for primary actions

❌ **Don't** create new asset paths - assets are in `lib/assets/images/`  
✅ **Do** use full path: `'lib/assets/images/filename.png'`

❌ **Don't** add new bottom nav items (fixed at 5)  
✅ **Do** use existing nav structure with FAB for submissions

## Testing & Quality
- Linting: `flutter_lints: ^6.0.0` (included)
- No unit tests currently implemented
- Run: `flutter analyze` to check for issues
- SDK: `^3.8.1`

## Future Integration Points (TODOs)
- Google OAuth (login/register screens)
- Backend API for user management, submissions, history
- Email verification
- Profile picture upload
- Forgot password flow
- Push notifications