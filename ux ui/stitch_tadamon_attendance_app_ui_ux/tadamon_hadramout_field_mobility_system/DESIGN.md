---
name: Tadamon Hadramout Field Mobility System
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#424751'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737782'
  outline-variant: '#c3c6d3'
  surface-tint: '#2b5ea7'
  primary: '#00346e'
  on-primary: '#ffffff'
  primary-container: '#0e4b94'
  on-primary-container: '#9bbeff'
  inverse-primary: '#aac7ff'
  secondary: '#195db2'
  on-secondary: '#ffffff'
  secondary-container: '#71a6ff'
  on-secondary-container: '#003a79'
  tertiary: '#5c2600'
  on-tertiary: '#ffffff'
  tertiary-container: '#7f3700'
  on-tertiary-container: '#ffa877'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d7e3ff'
  primary-fixed-dim: '#aac7ff'
  on-primary-fixed: '#001b3e'
  on-primary-fixed-variant: '#00458e'
  secondary-fixed: '#d6e3ff'
  secondary-fixed-dim: '#aac7ff'
  on-secondary-fixed: '#001b3e'
  on-secondary-fixed-variant: '#00458e'
  tertiary-fixed: '#ffdbca'
  tertiary-fixed-dim: '#ffb68e'
  on-tertiary-fixed: '#331200'
  on-tertiary-fixed-variant: '#763300'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
  surface-canvas: '#F8FAFC'
  surface-card: '#FFFFFF'
  border-subtle: '#E2E8F0'
  text-primary: '#0F172A'
  text-secondary: '#475569'
  status-present: '#15803D'
  status-present-bg: '#DCFCE7'
  status-excused: '#B45309'
  status-excused-bg: '#FEF3C7'
  status-unexcused: '#B91C1C'
  status-unexcused-bg: '#FEE2E2'
  status-session: '#4338CA'
  status-session-bg: '#EEF2FF'
typography:
  display-lg:
    fontFamily: Cairo
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: 0px
  headline-lg:
    fontFamily: Cairo
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: 0px
  headline-md:
    fontFamily: Cairo
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 26px
    letterSpacing: 0px
  headline-sm:
    fontFamily: Cairo
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0px
  body-lg:
    fontFamily: Cairo
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0px
  body-md:
    fontFamily: Cairo
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: 0px
  body-sm:
    fontFamily: Cairo
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0px
  label-lg:
    fontFamily: Cairo
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: 0px
  label-md:
    fontFamily: Cairo
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0px
  label-sm:
    fontFamily: Cairo
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.2px
  counter-display:
    fontFamily: Cairo
    fontSize: 24px
    fontWeight: '800'
    lineHeight: 28px
    letterSpacing: 0px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

The design system is engineered specifically for high-intensity athletic field environments. Designed for club administrators, team managers, and coaching staff working under direct sunlight on grass pitches, the interface prioritizes immediate legibility, one-handed thumb ergonomics, and zero visual ambiguity.

Rooted in the historical identity of Tadamon Hadramout Sports Club (established 1959), the visual direction fuses institutional athletic heritage with modern, utilitarian native mobile craft. The system abandons non-functional decorative treatments—such as blurred glassmorphic overlays, washed-out low-contrast gray typography, or heavy gradients—in favor of a high-contrast, structured, and tactical layout.

### Visual Character
- **Athletic Authority:** Anchored by the historic deep royal blue (`#0E4B94`) paired with clinical white cards and subtle slate borders.
- **Sunlight Readability:** Ultra-crisp contrast hierarchy exceeding WCAG AAA standards for text elements, ensuring legibility at maximum screen brightness under direct sun glare.
- **Tactile Ergonomics:** Chunky, deliberate touch targets (52–56dp height for primary call-to-actions) clustered within the bottom thumb reach zone.
- **Semantic Clarity:** Instant triage status colors (Field Emerald, Amber Gold, and Crimson Red) calibrated with matching high-contrast tinted backdrops for rapid 1-tap player roll calls.

## Colors

The color palette is built around the contrast ratio needed on pitch-side mobile screens.

### Palette Architecture
- **Primary (`#0E4B94`):** The club's royal blue. Used for dominant application headers, active navigation tabs, brand accents, and primary action buttons.
- **Secondary (`#1E60B5`):** Mid-tone athletic blue used for active pill states, focused strokes, and interactive links.
- **Neutral Base (`#0F172A`):** Deep midnight slate for high-clarity typography, counters, and high-emphasis icons.
- **Backgrounds (`#F8FAFC` & `#FFFFFF`):** A soft slate canvas prevents screen wash while maintaining sharp demarcation against pure white component cards.

### Semantic Status Tokens
Field status indicators rely on solid, saturated text/border colors paired with light-value container backgrounds (10–15% opacity equivalent):
- **Present (حاضر):** Foreground `#15803D` over `#DCFCE7`.
- **Excused (غائب بعذر):** Foreground `#B45309` over `#FEF3C7`.
- **Unexcused (غائب بدون عذر):** Foreground `#B91C1C` over `#FEE2E2`.
- **Session / Highlight:** Foreground `#4338CA` over `#EEF2FF`.

## Typography

The typographic system utilizes **Cairo** across all display, body, and label roles to provide geometric Arabic letterforms with consistent vertical x-height and open counters. This ensures that Arabic numbers, jersey positions, and player names remain legible at quick glances while holding a device with one hand outdoors.

### Typographic Rules & Direction
- **RTL-First Structure:** Natural alignment flows from right to left. Leading elements (such as jersey badges or icons) are anchored on the right edge, while actionable controls and toggles sit on the left edge.
- **Weight Calibration:** Light weights are avoided entirely. Body text defaults to regular (`400`) and medium (`500`), while headers and key player names use semibold (`600`) and bold (`700`).
- **Data Numbers:** Counters and numeric statistics leverage Cairo's tabular figure features or tabular alignments to avoid jitter during attendance updates.

## Layout & Spacing

The layout model is tailored for mobile viewport bounds (390×844pt to 412×915dp) optimized for vertical, single-column field interactions.

### The Pitch-Side Thumb Zone
- **Lower 25% Priority:** Floating action bars, primary validation buttons, and status toggles sit within comfortable reach of the thumb.
- **Top 25% Passive Area:** Used strictly for non-interactive state displays: club shield, session titles, date indicators, and search filters.

### Grid & Spacing Rhythm
- **Canvas Margins:** 16px (`margin: 1rem`) outer canvas padding to maximize screen real estate on mobile devices.
- **Card Spacing:** 8px to 12px gap between stacked player rows, ensuring distinct visual separation without causing excessive vertical scrolling.
- **Internal Card Padding:** Uniform 12px to 16px internal padding preserving compact heights (72–76dp total row height per player).

## Elevation & Depth

To maintain clarity under intense outdoor sun, the design system minimizes soft, multi-layered blur shadows that wash out outdoors. Depth is primarily established through clean structural borders, pure white container contrast over slate, and subtle tactile drop shadows.

### Surface Tiers
- **Tier 0 (Backdrop Canvas):** Soft Slate (`#F8FAFC`). Pure flat plane.
- **Tier 1 (Cards & Data Containers):** Pure White (`#FFFFFF`) with a 1px solid stroke in `#E2E8F0` and an ambient shadow: `0 1px 3px rgba(15, 23, 42, 0.05), 0 1px 2px rgba(15, 23, 42, 0.03)`.
- **Tier 2 (Bottom Sheets & Modals):** Pure White with a 1px top border in `#E2E8F0` and a directional shadow: `0 -4px 16px rgba(15, 23, 42, 0.08)`.
- **Tier 3 (Floating Action Bars / Fixed Thumb Trays):** Pure White surface with a solid 1px border stroke `#E2E8F0` and elevation shadow: `0 -2px 8px rgba(15, 23, 42, 0.06)`. No translucent blur filters.

## Shapes

The shape system adopts smooth squircle-like curves that balance modern athletic equipment aesthetics with functional mobile touch targets.

### Radius Assignments
- **Player Cards & Main Surface Containers:** 14px to 16px corner radius (`rounded-lg`), delivering soft contours that separate content sections clearly.
- **Icon Squircles:** 10px to 12px corner radius for Lucide icon badge enclosures.
- **Interactive Action Buttons (52–56dp):** 12px corner radius (`rounded-md`), keeping the click zone recognizable without degrading into round pill buttons for full-width actions.
- **Status Pills & Chips:** Fully rounded 9999px (capsule) for quick visual scanning of presence categories.

## Components

### Buttons & Interactive CTAs
- **Primary Action (54–56dp height):** Deep Royal Blue (`#0E4B94`) background with bold white typography (`#FFFFFF`). Minimum tap target width: full width minus outer margins (358px on standard 390px viewports). Active press state drops opacity to 90% with a slight scale transition (`scale(0.98)`).
- **Secondary Outlined (46–48dp height):** Pure white surface, 1.5px border `#E2E8F0`, midnight slate text (`#0F172A`).
- **Accelerator Button (48dp height):** Emerald Green (`#15803D`) full-width pill for bulk operations like "Mark All Present".

### Attendance Segmented Toggles
- Fixed within player list cards on the left edge (RTL).
- Three grouped touch areas (38×36dp minimum target each):
  - **Present:** Selected background `#15803D`, white text. Unselected: transparent background, `#475569` text.
  - **Excused:** Selected background `#B45309`, white text. Unselected: transparent background, `#475569` text.
  - **Absent:** Selected background `#B91C1C`, white text. Unselected: transparent background, `#475569` text.
- Selected state immediately provides 15ms haptic feedback.

### Player List Card Anatomy
- Outer Card: 1px border in `#E2E8F0`, 14px radius, white fill.
- Right Section:
  - Squircle jersey number badge (36×36dp, Royal Blue background, white bold numbers).
  - Two-tier text stack: Player Name (Bold 16sp, `#0F172A`) on top, playing position and status note (Regular 13sp, `#475569`) below.
- Left Section: 3-way attendance status pill cluster.

### Icon Containers (Lucide Icons)
- Standardized stroke weight of 1.75px.
- Encased inside 36×36dp or 40×40dp squircle boxes with a 10% semantic tint background matching the icon's state.

### Bottom Navigation Bar
- Height: 64dp plus bottom safe area inset.
- Background: Solid `#FFFFFF` with top border 1px `#E2E8F0`.
- 5 symmetric tabs with 22px Lucide icons and 11px Cairo label.
- Active state: `#0E4B94` icon and label with an active 4px dot indicator. Inactive state: `#64748B`.