# ⚡ TITAN — Design Specification

> Concrete design tokens, component definitions, and visual rules.
> Generated from the Design Brief. Used directly during implementation.

---

## Color Palette

### Primary Colors
| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| primary-50 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Lightest tint / backgrounds |
| primary-100 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Light tint |
| primary-200 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Hover states |
| primary-300 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Borders |
| primary-400 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Icons |
| primary-500 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | **Main brand color** |
| primary-600 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Hover on primary |
| primary-700 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Active/pressed |
| primary-800 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Dark variant |
| primary-900 | `#{{HEX}}` | `rgb({{R}}, {{G}}, {{B}})` | Darkest / text on light |

### Secondary Colors
| Name | Hex | Usage |
|------|-----|-------|
| secondary-500 | `#{{HEX}}` | Secondary actions, accents |

### Accent Colors
| Name | Hex | Usage |
|------|-----|-------|
| accent-500 | `#{{HEX}}` | Highlights, CTAs, attention |

### Neutral Colors
| Name | Hex | Usage |
|------|-----|-------|
| neutral-0 | `#FFFFFF` | White / page background |
| neutral-50 | `#{{HEX}}` | Subtle backgrounds |
| neutral-100 | `#{{HEX}}` | Card backgrounds, dividers |
| neutral-200 | `#{{HEX}}` | Borders |
| neutral-300 | `#{{HEX}}` | Disabled text |
| neutral-400 | `#{{HEX}}` | Placeholder text |
| neutral-500 | `#{{HEX}}` | Secondary text |
| neutral-600 | `#{{HEX}}` | Body text |
| neutral-700 | `#{{HEX}}` | Headings |
| neutral-800 | `#{{HEX}}` | Primary text |
| neutral-900 | `#{{HEX}}` | Darkest text |
| neutral-1000 | `#000000` | Black / dark mode background |

### Semantic Colors
| Name | Hex | Usage |
|------|-----|-------|
| success | `#{{HEX}}` | Positive states, confirmations |
| warning | `#{{HEX}}` | Caution states, alerts |
| error | `#{{HEX}}` | Error states, destructive actions |
| info | `#{{HEX}}` | Informational states |

### Dark Mode
| Token | Light Value | Dark Value |
|-------|-------------|------------|
| bg-primary | `neutral-0` | `neutral-900` |
| bg-secondary | `neutral-50` | `neutral-800` |
| text-primary | `neutral-800` | `neutral-100` |
| text-secondary | `neutral-500` | `neutral-400` |
| border | `neutral-200` | `neutral-700` |

---

## Typography

### Font Families
| Role | Family | Fallback Stack | Weight Range |
|------|--------|---------------|-------------|
| Headings | `{{HEADING_FONT}}` | `-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif` | 600-800 |
| Body | `{{BODY_FONT}}` | `-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif` | 400-600 |
| Monospace | `{{MONO_FONT}}` | `"SF Mono", "Fira Code", "Cascadia Code", monospace` | 400-500 |

### Type Scale
| Level | Size | Line Height | Weight | Letter Spacing | Usage |
|-------|------|-------------|--------|----------------|-------|
| display-xl | `3.5rem` (56px) | 1.1 | 800 | `-0.02em` | Hero headlines |
| display-lg | `3rem` (48px) | 1.15 | 700 | `-0.02em` | Page titles |
| h1 | `2.25rem` (36px) | 1.2 | 700 | `-0.01em` | Section headers |
| h2 | `1.875rem` (30px) | 1.25 | 600 | `-0.01em` | Sub-section headers |
| h3 | `1.5rem` (24px) | 1.3 | 600 | `0` | Card/panel headers |
| h4 | `1.25rem` (20px) | 1.4 | 600 | `0` | Group headers |
| h5 | `1.125rem` (18px) | 1.4 | 600 | `0.01em` | Minor headers |
| h6 | `1rem` (16px) | 1.5 | 600 | `0.01em` | Overlines, labels |
| body-lg | `1.125rem` (18px) | 1.6 | 400 | `0` | Lead paragraphs |
| body | `1rem` (16px) | 1.6 | 400 | `0` | Default body text |
| body-sm | `0.875rem` (14px) | 1.5 | 400 | `0.01em` | Secondary text |
| caption | `0.75rem` (12px) | 1.5 | 400 | `0.02em` | Captions, metadata |
| overline | `0.75rem` (12px) | 1.5 | 600 | `0.08em` | Labels, categories |

---

## Layout

### Grid System
| Property | Value |
|----------|-------|
| Type | CSS Grid / Flexbox |
| Columns | 12 |
| Gutter | `1.5rem` (24px) |
| Margin | `1rem` - `3rem` (responsive) |
| Max width | `1280px` |
| Content max | `768px` (prose) |

### Breakpoints
| Name | Min Width | Columns | Margin | Gutter |
|------|-----------|---------|--------|--------|
| `xs` | 0 | 4 | `1rem` | `1rem` |
| `sm` | `640px` | 6 | `1.5rem` | `1rem` |
| `md` | `768px` | 8 | `2rem` | `1.5rem` |
| `lg` | `1024px` | 12 | `2rem` | `1.5rem` |
| `xl` | `1280px` | 12 | `3rem` | `1.5rem` |
| `2xl` | `1536px` | 12 | auto | `1.5rem` |

---

## Spacing

### Spacing Scale
| Token | Value | Pixels | Usage |
|-------|-------|--------|-------|
| `space-0` | `0` | 0px | Reset |
| `space-px` | `1px` | 1px | Hairline borders |
| `space-0.5` | `0.125rem` | 2px | Minimal spacing |
| `space-1` | `0.25rem` | 4px | Tight inline spacing |
| `space-1.5` | `0.375rem` | 6px | — |
| `space-2` | `0.5rem` | 8px | Default inline spacing |
| `space-3` | `0.75rem` | 12px | Compact padding |
| `space-4` | `1rem` | 16px | Default padding |
| `space-5` | `1.25rem` | 20px | — |
| `space-6` | `1.5rem` | 24px | Card padding, gaps |
| `space-8` | `2rem` | 32px | Section spacing |
| `space-10` | `2.5rem` | 40px | — |
| `space-12` | `3rem` | 48px | Large section gaps |
| `space-16` | `4rem` | 64px | Page section spacing |
| `space-20` | `5rem` | 80px | Major section dividers |
| `space-24` | `6rem` | 96px | Hero spacing |

---

## Component Inventory

### Buttons

| Variant | Background | Text | Border | Radius | Padding |
|---------|-----------|------|--------|--------|---------|
| Primary | `primary-500` | `white` | none | `0.5rem` | `space-3 space-5` |
| Secondary | `transparent` | `primary-500` | `primary-500` | `0.5rem` | `space-3 space-5` |
| Ghost | `transparent` | `neutral-600` | none | `0.5rem` | `space-3 space-5` |
| Danger | `error` | `white` | none | `0.5rem` | `space-3 space-5` |
| Disabled | `neutral-100` | `neutral-400` | none | `0.5rem` | `space-3 space-5` |

**Sizes:** `sm` (32px height) | `md` (40px height) | `lg` (48px height)

### Inputs

| State | Border | Background | Text | Shadow |
|-------|--------|-----------|------|--------|
| Default | `neutral-200` | `white` | `neutral-800` | none |
| Hover | `neutral-300` | `white` | `neutral-800` | subtle |
| Focus | `primary-500` | `white` | `neutral-800` | `0 0 0 3px primary-100` |
| Error | `error` | `white` | `neutral-800` | `0 0 0 3px error/10%` |
| Disabled | `neutral-100` | `neutral-50` | `neutral-400` | none |

**Radius:** `0.375rem` | **Height:** `40px` (md) | **Padding:** `space-3`

### Cards

| Property | Value |
|----------|-------|
| Background | `white` (light) / `neutral-800` (dark) |
| Border | `neutral-200` or none with shadow |
| Radius | `0.75rem` |
| Padding | `space-6` |
| Shadow | `0 1px 3px rgba(0,0,0,0.1)` |
| Hover shadow | `0 4px 12px rgba(0,0,0,0.1)` |

### Navigation

| Element | Height | Background | Text | Active Indicator |
|---------|--------|-----------|------|-----------------|
| Navbar | `64px` | `white`/`neutral-900` | `neutral-700` | `primary-500` underline |
| Sidebar | `100vh` | `neutral-50`/`neutral-900` | `neutral-600` | `primary-50` background |
| Tabs | `48px` | `transparent` | `neutral-500` | `primary-500` border-bottom |
| Breadcrumb | `auto` | `transparent` | `neutral-500` | `neutral-800` (current) |

### Badges & Tags

| Variant | Background | Text | Radius |
|---------|-----------|------|--------|
| Default | `neutral-100` | `neutral-700` | `9999px` |
| Primary | `primary-50` | `primary-700` | `9999px` |
| Success | `success/10%` | `success` | `9999px` |
| Warning | `warning/10%` | `warning` | `9999px` |
| Error | `error/10%` | `error` | `9999px` |

### Modals & Dialogs

| Property | Value |
|----------|-------|
| Overlay | `rgba(0,0,0,0.5)` |
| Background | `white` / `neutral-800` |
| Radius | `1rem` |
| Shadow | `0 20px 60px rgba(0,0,0,0.3)` |
| Max width | `560px` (sm) / `720px` (md) / `960px` (lg) |
| Padding | `space-8` |

### Tooltips

| Property | Value |
|----------|-------|
| Background | `neutral-800` |
| Text | `white` |
| Radius | `0.375rem` |
| Padding | `space-1.5 space-3` |
| Font size | `caption` |
| Max width | `240px` |
| Delay | `300ms` |

---

## Interactive Behaviors

### Hover States
| Element | Effect | Transition |
|---------|--------|-----------|
| Buttons | Darken bg 10% | `150ms ease` |
| Links | Underline + color shift | `150ms ease` |
| Cards | Elevate shadow | `200ms ease` |
| Rows | Background highlight | `100ms ease` |

### Focus States
| Property | Value |
|----------|-------|
| Outline | `2px solid primary-500` |
| Offset | `2px` |
| Ring | `0 0 0 3px primary-100` |
| Visible | `:focus-visible` only (not `:focus`) |

### Transitions
| Type | Duration | Easing |
|------|----------|--------|
| Color/background | `150ms` | `ease` |
| Transform/shadow | `200ms` | `ease-out` |
| Layout/size | `250ms` | `ease-in-out` |
| Page transitions | `300ms` | `ease-in-out` |
| Modal enter | `200ms` | `ease-out` |
| Modal exit | `150ms` | `ease-in` |

### Loading States
| Type | Behavior |
|------|----------|
| Skeleton | Pulsing gray blocks matching content layout |
| Spinner | 24px circular, `primary-500`, `600ms` rotation |
| Progress | Horizontal bar, `primary-500`, animated fill |
| Button loading | Replace text with spinner, maintain width |

### Reduced Motion
```css
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}
```

---

## Icons & Assets

### Icon System
| Property | Value |
|----------|-------|
| Library | {{ICON_LIBRARY}} |
| Default size | `20px` (md) |
| Sizes | `16px` (sm) / `20px` (md) / `24px` (lg) / `32px` (xl) |
| Stroke width | `1.5px` |
| Color | `currentColor` (inherits text color) |

### Favicon & App Icons
| Asset | Size | Format |
|-------|------|--------|
| Favicon | 32x32 | `.ico` / `.svg` |
| Apple touch | 180x180 | `.png` |
| Android icon | 192x192, 512x512 | `.png` |
| OG image | 1200x630 | `.png` / `.jpg` |

### Image Handling
| Property | Value |
|----------|-------|
| Format | WebP with JPEG fallback |
| Lazy loading | Native (`loading="lazy"`) |
| Aspect ratios | 16:9 (hero) / 4:3 (card) / 1:1 (avatar) |
| Placeholder | Blur-up or dominant color |
| Max file size | 200KB (hero) / 100KB (content) / 50KB (thumbnail) |

---

## Border Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| `radius-none` | `0` | Sharp corners |
| `radius-sm` | `0.25rem` (4px) | Small elements, tags |
| `radius-md` | `0.375rem` (6px) | Inputs, small buttons |
| `radius-lg` | `0.5rem` (8px) | Buttons, dropdowns |
| `radius-xl` | `0.75rem` (12px) | Cards, panels |
| `radius-2xl` | `1rem` (16px) | Modals, large panels |
| `radius-full` | `9999px` | Pills, avatars |

---

## Shadow Scale

| Token | Value | Usage |
|-------|-------|-------|
| `shadow-xs` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle depth |
| `shadow-sm` | `0 1px 3px rgba(0,0,0,0.1)` | Cards, inputs |
| `shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Dropdowns, popovers |
| `shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Elevated cards |
| `shadow-xl` | `0 20px 25px rgba(0,0,0,0.15)` | Modals |
| `shadow-2xl` | `0 25px 50px rgba(0,0,0,0.25)` | Full-page overlays |

---

## Z-Index Scale

| Token | Value | Usage |
|-------|-------|-------|
| `z-below` | `-1` | Background decorations |
| `z-base` | `0` | Default content |
| `z-raised` | `10` | Sticky elements |
| `z-dropdown` | `20` | Dropdowns, popovers |
| `z-sticky` | `30` | Sticky headers |
| `z-overlay` | `40` | Overlays, backdrops |
| `z-modal` | `50` | Modals, dialogs |
| `z-toast` | `60` | Toast notifications |
| `z-tooltip` | `70` | Tooltips |

---

_Created: {{TIMESTAMP}}_
_TITAN v1.0_
