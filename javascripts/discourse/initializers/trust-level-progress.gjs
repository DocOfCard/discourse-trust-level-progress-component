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
  groupWithUsername(element) {
    const names = element.closest(".names");

    if (!names) {
      return;
    }

    // Keep username and trust-level title together as one wrapping unit.
    // When the row is too narrow, this whole unit moves to the next line.
    let group = names.querySelector(":scope > .trust-level-secondary-group");

    if (!group) {
      group = document.createElement("span");
      group.className = "trust-level-secondary-group";

      const username = names.querySelector(":scope > .second");
      const insertionPoint = username || element;
      names.insertBefore(group, insertionPoint);

      if (username) {
        group.appendChild(username);
      }
    }

    if (element.parentElement !== group) {
      group.appendChild(element);
    }
  }

  <template>
    {{#if this.title}}
      <span
        class="trust-level-title-on-post"
        {{didInsert this.groupWithUsername}}
      >
        {{#if this.badge}}
          <img class="trust-level-title-on-post__icon" src={{this.badge}} alt="" />
        {{/if}}
        <span>{{this.title}}</span>
      </span>
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
