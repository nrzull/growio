const buildFrontendRules = (name) => ({
  [`frontend/${name}/**/*.(vue)`]: (files) => [
    `npm run stylelint -w @growio/${name} -- ${files.join(" ")}`,
    `npm run eslint -w @growio/${name} -- ${files.join(" ")}`,
    `npm run vue-tsc -w @growio/${name}`,
  ],
  [`frontend/${name}/**/*.(js|ts)`]: (files) => [
    `npm run eslint -w @growio/${name} -- ${files.join(" ")}`,
    `npm run vue-tsc -w @growio/${name}`,
  ],
  [`frontend/${name}/**/*.(css)`]: (files) => [
    `npm run stylelint -w @growio/${name} -- ${files.join(" ")}`,
  ],
});

export default {
  "apps/**/*.(ex|exs)": () => ["mix test"],
  ...buildFrontendRules("marketplace"),
  ...buildFrontendRules("market"),
  ...buildFrontendRules("shared"),
};
