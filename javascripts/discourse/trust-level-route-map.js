export default {
  resource: "user",
  
  map() {
    this.route("trust-level", { path: "/trust-level" });
  },
};
