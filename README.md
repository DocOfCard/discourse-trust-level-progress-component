# Discourse Trust Level Progress Component

Version 3.2.3

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

## 3.2.1

- Added theme-component color settings for TL0-TL4 post titles.
- TL3 defaults to gold; TL4 defaults to purple.


## 3.2.1

- Fixes mobile ordering when a post shows only one user name: the trust-level label now stays after the user name on the same line.

## 3.2.2

- On mobile, keeps usernames and badge icons visible when horizontal space is limited.
- Clips only the trust-level title text instead of wrapping it onto another line or covering post metadata.
- Applies the same clipping behavior when only one user name is displayed.

## 3.2.3

- Re-applies the mobile username/title wrapper whenever Discourse switches between desktop and mobile layouts without a page reload.
- Restores the original DOM automatically when switching back to desktop.
- Uses the reactive `site.mobileView` service through an Ember modifier; no polling or MutationObserver.
