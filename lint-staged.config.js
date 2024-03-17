export default {
  "apps/**/*.(ex|exs)": () => ["mix test"],
  "frontend/marketplace/**/*.(vue)": (files) => [
    `npm run stylelint -w @growio/marketplace -- ${files.join(" ")}`,
    `npm run eslint -w @growio/marketplace -- ${files.join(" ")}`,
    "npm run vue-tsc -w @growio/marketplace",
  ],
  "frontend/marketplace/**/*.(js|ts)": (files) => [
    `npm run eslint -w @growio/marketplace -- ${files.join(" ")}`,
    "npm run vue-tsc -w @growio/marketplace",
  ],
  "frontend/marketplace/**/*.(css)": (files) => [
    `npm run stylelint -w @growio/marketplace -- ${files.join(" ")}`,
  ],
};
