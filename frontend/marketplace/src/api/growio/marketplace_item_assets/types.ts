export type MarketplaceItemAsset = {
  id: number;
  src: string;
  mimetype: string;
};

export type PartialMarketplaceItemAsset = Pick<
  MarketplaceItemAsset,
  "src" | "mimetype"
>;
