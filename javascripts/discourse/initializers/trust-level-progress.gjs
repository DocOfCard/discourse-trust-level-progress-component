import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];

function levelTitle(level) {
  const key = TRUST_LEVEL_KEYS[Number(level)];
  return key ? i18n(`trust_levels.names.${key}`) : `TL${level}`;
}

class PostTrustLevelTitle extends Component {
  get title() {
    const level = this.args.post?.trust_level;
    return level === undefined || level === null ? "" : levelTitle(level);
  }

  <template>
    {{#if this.title}}
      <span class="trust-level-title-on-post">{{this.title}}</span>
    {{/if}}
  </template>
}

export default {
  name: "trust-level-progress",

  initialize() {
    withPluginApi((api) => {
      if (settings.show_title_on_posts) {
        api.addTrackedPostProperties("trust_level");
        api.renderAfterWrapperOutlet(
          "post-meta-data-poster-name",
          PostTrustLevelTitle
        );
      }
    });
  },
};
