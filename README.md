# Discourse Trust Level Progress Component

Version 3.0.0

This theme component:

- adds a **Trust Level** tab after **Badges** on the signed-in user's profile;
- displays official TL1, TL2, and TL3 progress from the companion API plugin;
- shows the poster's trust-level name through Discourse's native `user-title` rendering path;
- uses the supplied TL0-TL4 SVG assets as the title icon.

## Version 3 poster-title implementation

The post title no longer inserts or moves DOM nodes. It uses the current Discourse poster-name transformers:

- `poster-name-class`
- `poster-name-user-title`

This keeps desktop and mobile ordering, wrapping, and alignment under Discourse's native poster-name component.

## Badge assets

Replace these files with your own SVGs while keeping the names unchanged:

```text
assets/badge-tl0.svg
assets/badge-tl1.svg
assets/badge-tl2.svg
assets/badge-tl3.svg
assets/badge-tl4.svg
```

Each SVG should have a tightly cropped and consistent `viewBox`.

## 3.1.3

- Added theme-component color settings for TL0-TL4 post titles.
- TL3 defaults to gold; TL4 defaults to purple.
