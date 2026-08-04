import Component from "@glimmer/component";
import { modifier } from "ember-modifier";
import DIcon from "discourse/components/d-icon";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];

export default class TrustLevelTitle extends Component {
  get post() {
    return this.args.outletArgs?.post;
  }

  get level() {
    const level = Number(
      this.post?.trust_level ?? this.args.outletArgs?.user?.trust_level
    );

    return Number.isInteger(level) && level >= 0 && level <= 4 ? level : null;
  }

  get title() {
    const key = TRUST_LEVEL_KEYS[this.level];
    return key ? i18n(`trust_levels.names.${key}`) : null;
  }

  get levelBadge() {
    return settings.theme_uploads?.[`badge_tl${this.level}`];
  }

  get nativeBadge() {
    return this.post?.title_badge || null;
  }

  get enabled() {
    return settings.show_title_on_posts && this.title;
  }

  get hasNativeBadgeVisual() {
    return Boolean(this.nativeBadge?.image_url || this.nativeBadge?.icon);
  }

  get nativeBadgeTooltip() {
    return (
      this.nativeBadge?.long_description ||
      this.nativeBadge?.description ||
      this.nativeBadge?.name
    );
  }

  enhanceNativeTitle = modifier((element) => {
    const names = element.closest(".names");
    if (!names) {
      return;
    }

    const nativeTitle = [...names.querySelectorAll(".user-title")].find(
      (title) =>
        !title.classList.contains("trust-level-title-on-post") &&
        !title.closest(".trust-level-title-display")
    );

    if (!nativeTitle) {
      return;
    }

    const fallbackTooltip = nativeTitle.textContent?.trim();
    const previousTitle = nativeTitle.getAttribute("title");

    nativeTitle.classList.add("trust-level-native-title-enhanced");

    const tooltip = this.nativeBadgeTooltip || fallbackTooltip;

    if (tooltip) {
      nativeTitle.setAttribute("title", tooltip);
      nativeTitle.setAttribute(
        "aria-label",
        this.nativeBadge?.name || fallbackTooltip
      );
    }

    if (this.hasNativeBadgeVisual) {
      nativeTitle.classList.add("trust-level-native-title-replaced");
      nativeTitle.setAttribute("aria-hidden", "true");
    }

    return () => {
      nativeTitle.classList.remove(
        "trust-level-native-title-enhanced",
        "trust-level-native-title-replaced"
      );
      nativeTitle.removeAttribute("aria-hidden");
      nativeTitle.removeAttribute("aria-label");

      if (previousTitle) {
        nativeTitle.setAttribute("title", previousTitle);
      } else {
        nativeTitle.removeAttribute("title");
      }
    };
  });

  <template>
    {{yield}}

    {{#if this.enabled}}
      <span
        class="trust-level-title-display"
        {{this.enhanceNativeTitle}}
      >
        {{#if this.hasNativeBadgeVisual}}
          <span
            class="trust-level-native-badge"
            title={{this.nativeBadgeTooltip}}
            aria-label={{this.nativeBadge.name}}
          >
            {{#if this.nativeBadge.image_url}}
              <img
                class="trust-level-native-badge__image"
                src={{this.nativeBadge.image_url}}
                alt=""
                loading="lazy"
              />
            {{else if this.nativeBadge.icon}}
              <DIcon
                @icon={{this.nativeBadge.icon}}
                class="trust-level-native-badge__icon"
              />
            {{/if}}
          </span>
        {{/if}}

        <span
          class="trust-level-title-on-post trust-level-title-on-post--tl{{this.level}}"
          title={{this.title}}
        >
          {{#if this.levelBadge}}
            <img
              class="trust-level-title-on-post__icon"
              src={{this.levelBadge}}
              alt=""
            />
          {{/if}}
          <span class="trust-level-title-on-post__text">{{this.title}}</span>
        </span>
      </span>
    {{/if}}
  </template>
}
