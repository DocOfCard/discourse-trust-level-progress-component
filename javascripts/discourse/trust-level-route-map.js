export default {
  resource: "user",
  path: "users/:username",
  map() {
    this.route("trust-level", { path: "/trust-level" });
  },
};
