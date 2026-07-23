import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class TrustLevelCurrentUserRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel() {
    if (!this.currentUser) {
      window.location.replace(
        `/login?redirect=${encodeURIComponent("/u/trust-level")}`
      );
      return;
    }

    const username =
      this.currentUser.username_lower || this.currentUser.username;

    // Use a real browser navigation instead of an Ember transition. `/u/trust-level`
    // overlaps with Discourse's `/u/:username` route, so an Ember transition can
    // leave the user model bound to the literal username "trust-level".
    window.location.replace(`/u/${encodeURIComponent(username)}/trust-level`);
  }
}
