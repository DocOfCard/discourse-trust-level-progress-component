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
  buildFixedPosterNameLayout(element) {
    const names = element.closest(".names");

    if (!names) {
      return;
    }

    names.classList.add("trust-level-names-layout");

    let userRow = names.querySelector(":scope > .trust-level-user-row");

    if (!userRow) {
      userRow = document.createElement("span");
      userRow.className = "trust-level-user-row";

      const displayName = names.querySelector(":scope > .first");
      if (displayName) {
        displayName.insertAdjacentElement("afterend", userRow);
      } else {
        names.appendChild(userRow);
      }
    }

    const username = names.querySelector(":scope > .second");
    if (username && username.parentElement !== userRow) {
      userRow.appendChild(username);
    }

    if (element.parentElement !== userRow) {
      userRow.appendChild(element);
    }
  }

  <template>
    {{#if this.title}}
      <span
        class="trust-level-title-on-post"
        {{didInsert this.buildFixedPosterNameLayout}}
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
