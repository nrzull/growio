export type MarketplaceItemCategory = {
  id: number;
  name: string;
  parent_id?: number;
};

export type PartialMarketplaceItemCategory = Pick<
  MarketplaceItemCategory,
  "name"
>;
