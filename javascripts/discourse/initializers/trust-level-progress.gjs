import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];

function trustLevelFor(context) {
  const level = Number(context.post?.trust_level ?? context.user?.trust_level);
  return Number.isInteger(level) && level >= 0 && level <= 4 ? level : null;
}

function trustLevelTitle(level) {
  return i18n(`trust_levels.names.${TRUST_LEVEL_KEYS[level]}`);
}

export default apiInitializer((api) => {
  if (!settings.show_title_on_posts) {
    return;
  }

  api.addTrackedPostProperties("trust_level");

  // Use Discourse's native poster-name classes so the trust-level title follows
  // the same desktop/mobile ordering and wrapping rules as the built-in user title.
  api.registerValueTransformer("poster-name-class", ({ value, context }) => {
    const level = trustLevelFor(context);

    if (level !== null) {
      value.push("trust-level-poster", `trust-level-poster--tl${level}`);
    }

    return value;
  });

  // Render the trust-level name through Discourse's built-in .user-title slot.
  // Preserve a user's existing title instead of replacing it.
  api.registerValueTransformer(
    "poster-name-user-title",
    ({ value, context }) => {
      const level = trustLevelFor(context);

      if (level === null) {
        return value;
      }

      const title = trustLevelTitle(level);
      return value ? `${value} · ${title}` : title;
    }
  );
});
