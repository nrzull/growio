export type MarketplaceItemCategory = {
  id: number;
  name: string;
};

export type PartialMarketplaceItemCategory = Pick<
  MarketplaceItemCategory,
  "name"
>;
