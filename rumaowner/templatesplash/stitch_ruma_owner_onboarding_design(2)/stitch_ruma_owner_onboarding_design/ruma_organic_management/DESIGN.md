---
name: RUMA Organic Management
colors:
  surface: '#fafaf3'
  surface-dim: '#dadad4'
  surface-bright: '#fafaf3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f4ed'
  surface-container: '#eeeee7'
  surface-container-high: '#e8e9e2'
  surface-container-highest: '#e3e3dc'
  on-surface: '#1a1c18'
  on-surface-variant: '#47483c'
  inverse-surface: '#2f312d'
  inverse-on-surface: '#f1f1ea'
  outline: '#77786b'
  outline-variant: '#c8c7b8'
  surface-tint: '#5a632e'
  primary: '#343c0a'
  on-primary: '#ffffff'
  primary-container: '#4b5320'
  on-primary-container: '#bdc787'
  inverse-primary: '#c3cc8c'
  secondary: '#5a6241'
  on-secondary: '#ffffff'
  secondary-container: '#dfe7bd'
  on-secondary-container: '#606847'
  tertiary: '#4a2d53'
  on-tertiary: '#ffffff'
  tertiary-container: '#62446b'
  on-tertiary-container: '#dab4e2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dfe8a6'
  primary-fixed-dim: '#c3cc8c'
  on-primary-fixed: '#191e00'
  on-primary-fixed-variant: '#434b18'
  secondary-fixed: '#dfe7bd'
  secondary-fixed-dim: '#c3cba3'
  on-secondary-fixed: '#181e05'
  on-secondary-fixed-variant: '#434a2b'
  tertiary-fixed: '#f9d8ff'
  tertiary-fixed-dim: '#e0bae8'
  on-tertiary-fixed: '#2b1034'
  on-tertiary-fixed-variant: '#593c62'
  background: '#fafaf3'
  on-background: '#1a1c18'
  surface-variant: '#e3e3dc'
  olive-drab: '#4B5320'
  sage-accent: '#A4AC86'
  cream-bg: '#FDFBF7'
  charcoal-text: '#1A1C18'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
---

## Brand & Style

The design system is built for RUMA, a property management platform that prioritizes stability, clarity, and trust for landlords. The brand personality is grounded and sophisticated, moving away from the cold, clinical feel of traditional real estate software toward an "Organic Professionalism." 

The design style is **Minimalism with a Tactile twist**. It utilizes heavy whitespace and a restricted, earthy palette to reduce cognitive load for users managing complex data. While the core philosophy is minimalist, the use of large corner radii and soft, ambient shadows provides a friendly, approachable physical presence that feels dependable and high-end.

## Colors

This design system employs a warm, nature-inspired palette to differentiate from the blue-heavy fintech and real estate space. 

- **Primary (Olive Green):** Used for primary actions, branding elements, and active states. It conveys authority and growth.
- **Secondary (Sage Green):** Used for subtle accents, secondary buttons, and progress indicators. It softens the interface and provides a sophisticated tonal variation.
- **Background (Cream):** The off-white base reduces eye strain and makes the interface feel more premium and "furnished" compared to pure white.
- **Surface (White):** Reserved strictly for cards and elevated components to create clear visual separation from the background.
- **Text (Charcoal):** High-contrast but softer than pure black, ensuring excellent readability for dense property data.

## Typography

The design system utilizes **Inter** for its exceptional legibility and systematic feel. The typography follows a strict hierarchy to help landlords quickly scan financial figures and tenant information.

Headlines use tighter letter spacing and heavier weights to anchor sections. Body copy is optimized for readability with generous line heights. Labels use a slightly increased letter spacing and uppercase styling for "Meta" information like status badges or small section headers, ensuring they are distinct from interactive text.

## Layout & Spacing

This design system uses a **fluid grid** model optimized for mobile-first property management. The layout relies on a 4px baseline grid to ensure consistent vertical rhythm.

- **Mobile:** 4-column fluid grid with 20px outside margins and 16px gutters.
- **Tablet/Desktop:** 12-column grid with a maximum content width of 1200px.
- **Rhythm:** Spacing between cards should be consistent at `lg` (24px) to maintain the airy, minimalist feel. Internal card padding should never be less than `md` (16px).

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layers** supplemented by **Ambient Shadows**. 

The background sits at the lowest level (`cream-bg`). Cards and interactive surfaces sit at the middle level (`white`). Shadows are not used to denote "height" in the traditional skeuomorphic sense, but rather to create a soft separation between the surface and the background. 

Shadows should be extra-diffused with low opacity (e.g., `y-offset: 4px, blur: 20px, opacity: 0.04`) and use a slight olive-tinted neutral color rather than pure gray, maintaining the earthy warmth of the design system.

## Shapes

The shape language is defined by a "Rounded" philosophy to evoke friendliness and safety.

- **Standard Components:** Buttons and input fields use a 0.5rem (8px) radius.
- **Containers (Cards):** Property cards and modals use a 1rem (16px) radius to create a soft, modern container.
- **Selection Elements:** Checkboxes use a slightly softened 4px radius, while radio buttons remain fully circular. 

Avoid sharp 0px corners entirely to maintain the approachable brand voice.

## Components

### Buttons
Primary buttons are solid Olive Green with White text. Secondary buttons use the Sage Green background with Olive Green text. All buttons should have a minimum height of 48px for mobile accessibility.

### Cards
The centerpiece of the app. Cards must be white, use a 16px corner radius, and feature a subtle ambient shadow. Use internal padding of 20px. Titles within cards should be `headline-md`.

### Input Fields
Fields should have a subtle 1px border in a muted version of Sage Green. Labels sit above the field using the `label-md` style. Focus states should transition the border to Olive Green with a 2px stroke.

### Chips & Status Badges
Used for property status (e.g., "Occupied," "Vacant"). These use high-clearance rounded corners (pill-shaped) and a background color that is a 10% opacity version of the status color (e.g., Sage for success, a muted red for urgent alerts).

### Lists
Lists of tenants or payments should avoid divider lines where possible, instead using whitespace or very subtle background shifts between items to maintain the minimalist aesthetic.