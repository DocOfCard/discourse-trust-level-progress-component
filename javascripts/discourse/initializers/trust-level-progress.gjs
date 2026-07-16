import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

function levelTitle(level) {
  return i18n(themePrefix(`trust_level_progress.levels.${level}`));
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
