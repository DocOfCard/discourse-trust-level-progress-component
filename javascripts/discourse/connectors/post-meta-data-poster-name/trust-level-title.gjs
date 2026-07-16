import Component from "@glimmer/component";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { and } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];

export default class TrustLevelTitle extends Component {
  @service site;

  get level() {
    const level = Number(
      this.args.outletArgs?.post?.trust_level ??
        this.args.outletArgs?.user?.trust_level
    );

    return Number.isInteger(level) && level >= 0 && level <= 4 ? level : null;
  }

  get title() {
    const key = TRUST_LEVEL_KEYS[this.level];
    return key ? i18n(`trust_levels.names.${key}`) : null;
  }

  get badge() {
    return settings.theme_uploads?.[`badge_tl${this.level}`];
  }

  get enabled() {
    return settings.show_title_on_posts;
  }

  mobileUserRow = modifier((titleElement, [mobileView]) => {
    if (!mobileView) {
      return;
    }

    const names = titleElement.closest(".names");
    const username = names?.querySelector(":scope > .second");

    if (!names || !username) {
      return;
    }

    let row = names.querySelector(":scope > .trust-level-user-row");

    if (!row) {
      row = document.createElement("span");
      row.className = "trust-level-user-row";
      names.insertBefore(row, username);
    }

    row.append(username, titleElement);

    return () => {
      if (!names.isConnected || !row.isConnected) {
        return;
      }

      if (username.isConnected) {
        names.insertBefore(username, row);
      }

      if (titleElement.isConnected) {
        names.insertBefore(titleElement, row);
      }

      row.remove();
    };
  });

  <template>
    {{yield}}

    {{#if (and this.enabled this.title)}}
      <span
        class="trust-level-title-on-post trust-level-title-on-post--tl{{this.level}}"
        {{this.mobileUserRow this.site.mobileView}}
      >
        {{#if this.badge}}
          <img
            class="trust-level-title-on-post__icon"
            src={{this.badge}}
            alt=""
          />
        {{/if}}
        <span class="trust-level-title-on-post__text">{{this.title}}</span>
      </span>
    {{/if}}
  </template>
}
