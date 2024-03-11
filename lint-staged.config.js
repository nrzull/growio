export default {
  "apps/**/*.(ex|exs)": () => ["mix test"],
  "frontend/marketplace/**/*.(vue|js|ts)": (files) => [
    `npm run lint:eslint -w @growio/marketplace -- ${files.join(" ")}`,
    "npm run lint:ts -w @growio/marketplace",
  ],
  "frontend/marketplace/**/*.(vue|css)": (files) => [
    `npm run lint:stylelint -w @growio/marketplace -- ${files.join(" ")}`,
  ],
};
