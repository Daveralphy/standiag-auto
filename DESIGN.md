# DESIGN.md — StanDiag Auto Design System

The visual language of StanDiag Auto. Every screen is built from these tokens.
Never hardcode values. Always reference constants from `/lib/core/constants/`.

---

## Brand Identity

**App Name:** StanDiag Auto
**Tagline:** Your mechanic, on demand.
**Logo Icon:** `/assets/images/logo_icon.png`
**Full Logo:** `/assets/images/logo_full.png`
**Design Personality:** Dark, bold, modern, high-contrast, Gen Z energy with professional UX.

---

## Color Palette

All colors are defined in `/lib/core/constants/app_colors.dart`.

### Background Colors
| Token | Hex | Usage |
|---|---|---|
| `AppColors.background` | `#0A0A0A` | Main app background, all screens |
| `AppColors.backgroundPage` | `#0D0D0D` | Outer page background |
| `AppColors.surface` | `#141414` | Cards, drawers, modals |
| `AppColors.surfaceElevated` | `#1A1A1A` | Elevated cards, error toasts |

### Primary Colors
| Token | Hex | Usage |
|---|---|---|
| `AppColors.primary` | `#E8281E` | Buttons, active states, accents, stars |
| `AppColors.primaryDark` | `#C41F16` | Button gradient end, pressed states |
| `AppColors.primaryLight` | `#F03328` | Button gradient start |
| `AppColors.primarySubtle` | `rgba(232,40,30,0.08)` | Card tints on selected state |
| `AppColors.primaryBorder` | `rgba(232,40,30,0.2)` | Card borders on selected state |

### Text Colors
| Token | Value | Usage |
|---|---|---|
| `AppColors.textPrimary` | `#FFFFFF` | Main text, headings |
| `AppColors.textSecondary` | `rgba(255,255,255,0.7)` | Secondary labels |
| `AppColors.textMuted` | `rgba(255,255,255,0.4)` | Subtitles, hints |
| `AppColors.textDim` | `rgba(255,255,255,0.25)` | Very muted text, placeholders |
| `AppColors.textDisabled` | `rgba(255,255,255,0.2)` | Disabled/inactive states |

### Semantic Colors
| Token | Hex | Usage |
|---|---|---|
| `AppColors.success` | `#4CAF50` | Job completed, online status, good scores |
| `AppColors.warning` | `#FFC107` | Star ratings, pending states |
| `AppColors.amber` | `#F59E0B` | Filled stars in ratings |
| `AppColors.blue` | `#3B82F6` | Mechanic pin on map, OBD connected |

### Border Colors
| Token | Value | Usage |
|---|---|---|
| `AppColors.border` | `rgba(255,255,255,0.07)` | Card borders, dividers |
| `AppColors.borderSubtle` | `rgba(255,255,255,0.05)` | Very subtle dividers |
| `AppColors.borderActive` | `rgba(255,255,255,0.1)` | Active input borders |
| `AppColors.borderFocus` | `#E8281E` | Focused input borders |

---

## Typography

All fonts are Inter. Font files are in `/assets/fonts/Inter/`.
All text styles are defined in `/lib/core/constants/app_typography.dart`.

| Token | Size | Weight | Usage |
|---|---|---|---|
| `AppTypography.display` | 26–28px | 900 | Page titles (Who are you?) |
| `AppTypography.heading1` | 22–24px | 900 | Section headers |
| `AppTypography.heading2` | 18–20px | 800–900 | Card titles, user names |
| `AppTypography.heading3` | 15–16px | 800 | Screen headers, nav titles |
| `AppTypography.body` | 12–13px | 500–600 | Body text, list items |
| `AppTypography.bodySmall` | 11–11.5px | 400–500 | Subtitles, descriptions |
| `AppTypography.caption` | 9.5–10px | 500–600 | Labels, meta text |
| `AppTypography.micro` | 8.5–9px | 600–700 | Tags, badges, tiny labels |

**Letter spacing:** All headings use `-0.4px` to `-0.8px` negative tracking.
**Line height:** 1.0–1.1 for headings, 1.5–1.7 for body and captions.

---

## Spacing

All spacing values are defined in `/lib/core/constants/app_spacing.dart`.

| Token | Value | Usage |
|---|---|---|
| `AppSpacing.xxs` | 4 | Icon gaps, tight internal padding |
| `AppSpacing.xs` | 6 | Small gaps between inline elements |
| `AppSpacing.sm` | 8 | Button inner padding, small card gaps |
| `AppSpacing.md` | 12 | Card internal padding, list item spacing |
| `AppSpacing.lg` | 18 | Screen horizontal padding, section gaps |
| `AppSpacing.xl` | 24 | Large section spacing |
| `AppSpacing.xxl` | 32 | Page-level spacing, large gaps |

---

## Border Radius

All radius values are defined in `/lib/core/constants/app_radius.dart`.

| Token | Value | Usage |
|---|---|---|
| `AppRadius.xs` | 8 | Small tags, close buttons |
| `AppRadius.sm` | 10–12 | Input fields, small buttons |
| `AppRadius.md` | 14–16 | Standard cards, modals |
| `AppRadius.lg` | 18–20 | Large cards, profile cards |
| `AppRadius.xl` | 24–28 | Drawers, bottom sheets |
| `AppRadius.full` | 99 | Pills, circular buttons, nav bar |
| `AppRadius.phone` | 54 | Phone frame (design reference only) |

---

## Components

### Primary Button (3D Pill)
- Shape: `border-radius: 99px` (pill)
- Background: `linear-gradient(180deg, #F03328 0%, #C41F16 100%)`
- Box shadow:
  - `inset 0 1.5px 0 rgba(255,255,255,0.28)` — top highlight
  - `inset 0 -2px 0 rgba(0,0,0,0.22)` — bottom shadow
  - `0 2px 6px rgba(130,15,10,0.5)` — near glow
  - `0 6px 20px rgba(232,40,30,0.22)` — far glow
- Text: white, 13–14px, weight 700
- Height: 46–50px

### Ghost Button
- Shape: `border-radius: 14px`
- Background: `rgba(255,255,255,0.05)`
- Border: `1px solid rgba(255,255,255,0.08)`
- Text: `rgba(255,255,255,0.45)`, 13px, weight 600

### Input Field (Floating Label)
- Background: `rgba(255,255,255,0.04)`
- Border: `1px solid rgba(255,255,255,0.1)`
- Border radius: 12px
- Height: 48px
- Label: positioned absolutely, top `-7px`, left `11px`, on app background color
- Focus border: `1px solid #E8281E`
- Focus label color: `#E8281E`

### Card
- Background: `#141414`
- Border: `1px solid rgba(255,255,255,0.07)`
- Border radius: 16–20px

### Selected Card
- Background: `rgba(232,40,30,0.06)`
- Border: `1.5px solid #E8281E`

### Navigation Bar (Floating Pill)
- Position: fixed, bottom `16px`, left `16px`, right `16px`
- Height: 60px
- Background: `rgba(14,14,14,0.88)` with `backdrop-filter: blur(20px)`
- Border: `1px solid rgba(255,255,255,0.08)`
- Border radius: 28px
- Active item: protrudes upward, red circle `46x46px`, `margin-top: -18px`
- Active circle: red gradient, `border: 3px solid #0A0A0A`, glow shadow

### Tags / Expertise Pills
- Background: `rgba(255,255,255,0.05)`
- Border: `1px solid rgba(255,255,255,0.08)`
- Border radius: 99px
- Padding: `3px 8px`
- Text: 8.5px, weight 600, `rgba(255,255,255,0.35)`

### Toggle (On/Off)
- Width: 42px, height: 24px
- Border radius: 99px
- On: background `#E8281E`, thumb at `translateX(18px)`
- Off: background `rgba(255,255,255,0.12)`, thumb at `translateX(2px)`
- Thumb: 20x20px white circle

### OTP Input Boxes
- 6 boxes, each 38x48px
- Background: `rgba(255,255,255,0.04)`
- Border: `1px solid rgba(255,255,255,0.1)`
- Border radius: 12px
- Active/filled border: `1px solid #E8281E`

---

## Map Style

Dark city map with:
- Background: `#0F1218`
- Roads (main): `#182028`
- Roads (secondary): `#141B22`
- Buildings: `#111820`
- Parks/green areas: `#0D1A10` with `#142016` border

**User pin:** Red dot — `#E8281E` with radial glow
**Mechanic pin:** Dark circle `#1A2535` with `#3B82F6` border, mechanic emoji inside
**Route line:** `#3B82F6`, dashed `5px/4px`, 50% opacity

---

## Animations

All animations should feel fluid and natural. Gen Z interfaces are alive.

| Animation | Duration | Curve | Usage |
|---|---|---|---|
| Screen transitions | 300ms | `easeInOut` | Page navigation |
| Card press | 100ms | `easeIn` | Button/card tap feedback |
| Toast appear | 250ms | `easeOut` | Error toast slide up |
| Toast dismiss | 200ms | `easeIn` | Error toast fade out |
| Skeleton shimmer | 1500ms | `linear` | Loading states |
| Online blink | 1500ms | `easeInOut` | Online status dot |
| Spinner | 900ms | `linear` | Loading spinner |
| Drawer slide | 280ms | `easeInOut` | Side drawer open/close |
| Call rings | 2000ms | `easeInOut` | Pulsing rings on call screen |
| Map pin pulse | 2000ms | `easeInOut` | Location pin glow |

---

## Status Bar

Time: `9:41`, 9px, weight 600, white
Icons (left to right): signal bars, WiFi arcs, battery rectangle
All icons: white

---

## Screen Header Pattern

All secondary screens:
```
[← back]  Screen Title
```

All primary screens (user):
```
[avatar]  Title          [bell icon with optional dot]
          Subtitle
```

All primary map screens (both):
```
[avatar]  Title          [search icon]
          Subtitle
```

All primary mechanic screens:
```
[avatar]  Title          [bell icon] (home/scan only)
          Subtitle       [search icon] (users/map screen only)
```

---

## Image Assets

| File | Usage |
|---|---|
| `logo_icon.png` | Splash screen 1, app icon |
| `logo_full.png` | Splash screen 2 |
| `onboarding_1.png` | Onboarding screen 1 background |
| `onboarding_2.png` | Onboarding screen 2 background |
| `onboarding_3.png` | Onboarding screen 3 background |

All images are in `/assets/images/`.
User and mechanic profile photos are stored in Firebase Storage and loaded via URL.
All network images must have a placeholder skeleton while loading.
