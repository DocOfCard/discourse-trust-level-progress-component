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

  get customTitleEnabled() {
    return (
      settings.show_title_on_posts &&
      settings.show_custom_trust_level_title &&
      !settings.show_native_trust_level_title
    );
  }

  get nativeTitleEnabled() {
    return (
      settings.show_title_on_posts && settings.show_native_trust_level_title
    );
  }

  decorateNativeTitles = modifier((element) => {
    const names = element.closest(".names");

    if (!names) {
      return;
    }

    const decorated = [];

    for (const title of names.querySelectorAll(".user-title")) {
      if (!title.hasAttribute("title")) {
        const label = title.textContent?.trim();

        if (label) {
          title.setAttribute("title", label);
          decorated.push(title);
        }
      }
    }

    return () => {
      for (const title of decorated) {
        title.removeAttribute("title");
      }
    };
  });

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

    <span
      class="trust-level-title-controller"
      aria-hidden="true"
      {{this.decorateNativeTitles}}
    ></span>

    {{#if (and this.nativeTitleEnabled this.title)}}
      <span
        class="user-title trust-level-title-on-post trust-level-title-on-post--native trust-level-title-on-post--tl{{this.level}}"
        title={{this.title}}
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
    {{else if (and this.customTitleEnabled this.title)}}
      <span
        class="trust-level-title-on-post trust-level-title-on-post--custom trust-level-title-on-post--tl{{this.level}}"
        title={{this.title}}
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
