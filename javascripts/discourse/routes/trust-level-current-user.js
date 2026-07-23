import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class TrustLevelCurrentUserRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel() {
    if (!this.currentUser) {
      window.location.assign(
        `/login?redirect=${encodeURIComponent("/u/trust-level")}`
      );
      return;
    }

    this.replaceWith(
      "user.trust-level",
      this.currentUser.username_lower || this.currentUser.username
    );
  }
}
