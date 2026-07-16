import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  if (settings.show_title_on_posts) {
    api.addTrackedPostProperties("trust_level");
  }
});
