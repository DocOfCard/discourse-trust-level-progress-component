import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];

function levelTitle(level) {
  const key = TRUST_LEVEL_KEYS[Number(level)];
  return key ? i18n(`trust_levels.names.${key}`) : `TL${level}`;
}

function levelBadge(level) {
  return settings.theme_uploads?.[`badge_tl${Number(level)}`];
}

class PostTrustLevelTitle extends Component {
  get level() {
    return this.args.post?.trust_level;
  }

  get title() {
    return this.level === undefined || this.level === null
      ? ""
      : levelTitle(this.level);
  }

  get badge() {
    return this.title ? levelBadge(this.level) : null;
  }

  @action
  moveBelowPosterNames(element) {
    const topicMetaData = element.closest(".topic-meta-data");
    const names = topicMetaData?.querySelector(":scope > .names");

    if (!topicMetaData || !names) {
      return;
    }

    // Make the title a direct child of topic-meta-data so the grid layout is
    // identical on desktop and mobile.
    if (element.parentElement !== topicMetaData) {
      topicMetaData.insertBefore(element, topicMetaData.querySelector(":scope > .post-infos"));
    }
  }

  <template>
    {{#if this.title}}
      <div
        class="trust-level-title-on-post"
        {{didInsert this.moveBelowPosterNames}}
      >
        {{#if this.badge}}
          <img class="trust-level-title-on-post__icon" src={{this.badge}} alt="" />
        {{/if}}
        <span>{{this.title}}</span>
      </div>
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
