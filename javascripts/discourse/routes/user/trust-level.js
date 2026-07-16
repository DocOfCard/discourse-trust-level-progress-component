import DiscourseRoute from "discourse/routes/discourse";

export default class UserTrustLevelRoute extends DiscourseRoute {
  model() {
    return this.modelFor("user");
  }
}
