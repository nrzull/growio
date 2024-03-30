module.exports = {
  extends: ["plugin:vue/vue3-recommended"],
  parser: "vue-eslint-parser",
  parserOptions: {
    parser: "@typescript-eslint/parser",
    sourceType: "module",
  },
  rules: {
    "vue/multi-word-component-names": "off",
    "vue/max-attributes-per-line": "off",
    "vue/html-self-closing": "off",
  },
};
