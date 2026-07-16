import { service } from "@ember/service";
import Component from "@glimmer/component";
import DNavigationItem from "discourse/ui-kit/d-navigation-item";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class TrustLevelNavItem extends Component {
  @service currentUser;

  get user() {
    return this.args.outletArgs?.model;
  }

  get canDisplay() {
    return Boolean(
      settings.show_profile_progress &&
        this.currentUser &&
        this.user &&
        (this.currentUser.id === this.user.id ||
          this.currentUser.username_lower === this.user.username_lower ||
          this.currentUser.username === this.user.username)
    );
  }

  <template>
    {{#if this.canDisplay}}
      <DNavigationItem
        @route="user.trust-level"
        class="user-nav__trust-level"
      >
        {{dIcon "shield-halved"}}
        <span>{{i18n (themePrefix "trust_level_progress.nav_title")}}</span>
      </DNavigationItem>
    {{/if}}
  </template>
}
