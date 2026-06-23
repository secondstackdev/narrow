# Brand & Design System

> Created once per project using `/shape --brand`. Referenced by all scopes.
> Updated during cooldown only — not during cycles.

## Brand Identity

### Voice & Tone
[How the product speaks: e.g., warm and encouraging, never clinical or pressuring.]

### Personality
[3-5 adjectives that describe the product's character.]

## Design Tokens

### Typography
- **Display font:** [Font name — distinctive, characterful. Never Inter/Roboto/Arial.]
- **Body font:** [Font name — readable, pairs well with display font.]
- **Monospace:** [Font name — for code or data, if applicable.]
- **Type scale:** [e.g., 12/14/16/20/24/32/48 — or reference a modular scale.]

### Colour Palette
- **Primary:** [hex] — [when to use]
- **Secondary:** [hex] — [when to use]
- **Accent:** [hex] — [when to use, sparingly]
- **Neutral light:** [hex] — [backgrounds, cards]
- **Neutral dark:** [hex] — [text, borders]
- **Success:** [hex]
- **Warning:** [hex]
- **Error:** [hex]
- **Surface/Background:** [hex or gradient description]

### Spacing & Layout
- **Base unit:** [e.g., 4px or 8px grid]
- **Content max-width:** [e.g., 1200px]
- **Layout philosophy:** [e.g., generous whitespace, card-based, asymmetric]

### Motion & Animation
- **Philosophy:** [e.g., subtle and purposeful, never decorative for its own sake]
- **Timing:** [e.g., 200ms for micro-interactions, 400ms for transitions]
- **Easing:** [e.g., ease-out for enters, ease-in for exits]
- **Key moments:** [e.g., page load stagger, hover reveals, scroll triggers]

### Backgrounds & Texture
- **Style:** [e.g., atmospheric gradients, noise texture, solid minimal]
- **Dark/light mode:** [which is primary, or both]

## Component Patterns

### Buttons
[Primary, secondary, ghost/text styles. Sizes. States: hover, active, disabled, loading.]

### Cards
[Standard card structure. Shadow, border-radius, padding, image handling.]

### Forms
[Input style, label placement, validation display, error states.]

### Navigation
[Primary nav pattern, mobile nav, breadcrumbs if applicable.]

### Empty States
[Every screen must have a designed empty state — never a blank page.]

### Loading States
[Skeleton screens, spinners, or progressive loading approach.]

### Error States
[Designed error messages — not raw alerts. Tone matches brand voice.]

## Accessibility Requirements

- Minimum contrast ratio: [e.g., 4.5:1 for body text, 3:1 for large text]
- Focus indicators: [visible, styled to match brand]
- Screen reader: [semantic HTML, ARIA labels where needed]
- Reduced motion: [respect `prefers-reduced-motion`]

## Platform Notes

[Any platform-specific design considerations — e.g., iOS patterns for a mobile app, responsive breakpoints for web.]

---

*This file is the single source of truth for visual design decisions. The frontend-design skill and all scope mockups reference this file. Do not deviate without updating this document during cooldown.*
