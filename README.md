# Discourse Trust Level Progress Component

Public, frontend-only Discourse Theme Component.

Features:

- Displays the trust-level title beside post authors.
- Displays exact promotion progress on the signed-in user's own profile when the companion API plugin is installed.
- Includes desktop and mobile styling.
- Operates safely without the API plugin: missing, unavailable, or unauthorized API responses are handled silently and the progress card is hidden.

Companion endpoint:

`GET /trust-level-progress/progress.json`

Install `discourse-trust-level-progress-api` to enable the profile progress card. The post trust-level title works independently. Visual and wording changes can be deployed by updating this Theme Component without rebuilding the Discourse container.

- TL1、TL2、TL3 均使用统一的四列表格展示：要求项目、状态、当前值、要求值。


## Trust level SVG assets

Replace the five placeholder files in `assets/` with the real badge artwork. Keep these exact file names:

- `assets/badge-tl0.svg`
- `assets/badge-tl1.svg`
- `assets/badge-tl2.svg`
- `assets/badge-tl3.svg`
- `assets/badge-tl4.svg`

The component automatically displays the matching SVG before trust-level names on the profile progress page and beside post-author trust-level titles.
