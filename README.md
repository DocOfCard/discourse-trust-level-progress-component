# Discourse Trust Level Progress Component

Version 4.0.4

This theme component:

- adds a **Trust Level** tab after **Badges** on the signed-in user's profile;
- displays official TL1, TL2, and TL3 progress from the companion API plugin;
- shows the poster's trust-level name through the `post-meta-data-poster-name` connector;
- uses the supplied TL0-TL4 SVG assets as the title icon.

## Post title implementation

Post trust-level titles are rendered by:

```text
javascripts/discourse/connectors/post-meta-data-poster-name/trust-level-title.gjs
```

Desktop keeps Discourse's normal poster-name DOM. On mobile, the component creates a minimal temporary wrapper around the username and trust-level title so they wrap as one unit. The wrapper is removed automatically when switching back to desktop.

## Stylesheet structure

Styles follow Discourse theme-component conventions:

```text
common/common.scss
 desktop/desktop.scss
 mobile/mobile.scss
```

- `common/common.scss` contains shared post-title and profile-progress styles.
- `desktop/desktop.scss` places the trust-level and achievement cards side by side and allows the value column to wrap.
- `mobile/mobile.scss` contains the compact progress layout and the mobile username/title wrapping rules.

## JavaScript structure

The JavaScript/GJS files remain separated because each file has a distinct Discourse or Ember responsibility:

```text
javascripts/discourse/components/                 Progress UI and data loading
javascripts/discourse/connectors/                 Post title and profile navigation outlets
javascripts/discourse/initializers/                Tracked post property registration
javascripts/discourse/routes/                      User profile route model
javascripts/discourse/templates/                   User profile route template
javascripts/discourse/trust-level-route-map.js     Route declaration
```

No compatibility layer, polling loop, MutationObserver, or duplicate legacy implementation is included.

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

## Changelog

### 4.0.0

- Reorganized SCSS into the official `common`, `desktop`, and `mobile` theme folders.
- Kept all existing post-title, mobile layout, profile navigation, progress API, localization, settings, and SVG behavior unchanged.
- Documented why the separate JavaScript/GJS files are required by their Discourse and Ember responsibilities.
- Preserved the project description, author, repository, license, compatibility, settings, and asset metadata in `about.json`.

### 3.2.6

- Updated documentation to match the current connector and mobile wrapper implementation.
- Corrected the English TL4 color description.
- Removed redundant SVG size constraints without changing the rendered size.

### 3.2.5

- Further softened the default TL0-TL4 title colors.
- Kept the post title font weight at 500.

### 3.2.4

- Re-applies the mobile username/title wrapper whenever Discourse switches between desktop and mobile layouts without a page reload.
- Restores the original DOM automatically when switching back to desktop.
- Uses the reactive `site.mobileView` service through an Ember modifier; no polling or MutationObserver.
- Softened default trust-level colors to reduce visual dominance.
- Reduced post trust-level title weight from 600 to 500.

### 3.2.2

- Keeps usernames and badge icons visible on mobile when horizontal space is limited.
- Clips only the trust-level title text instead of wrapping it onto another line or covering post metadata.
- Applies the same clipping behavior when only one user name is displayed.

### 3.2.1

- Added theme-component color settings for TL0-TL4 post titles.
- Fixed mobile ordering when a post shows only one user name, keeping the trust-level title after the user name on the same line.


## v4.0.2

- Separates Gamification data from the Trust Level card.
- Adds editable theme settings for Gamification scoring rules.
- Displays all configured scoring rules directly on the profile page.


## 4.0.3

- Moved trust-level promotion requirements into the trust-level summary card.
- Added `show_zero_score_rules` (default off) to hide zero-value Gamification rules while preserving the configured rule order.
