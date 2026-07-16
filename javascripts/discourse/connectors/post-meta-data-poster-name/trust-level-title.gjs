import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];

export default class TrustLevelTitle extends Component {
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

  <template>
    {{#if this.title}}
      <span
        class="trust-level-title-on-post trust-level-title-on-post--tl{{this.level}}"
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
