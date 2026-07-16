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
