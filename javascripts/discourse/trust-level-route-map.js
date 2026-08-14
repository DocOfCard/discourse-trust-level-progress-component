export default {
  resource: "user",
  path: "/u/:username",

  map() {
    this.route("trust-level", { path: "/trust-level" });
  },
};
