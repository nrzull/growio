export type MarketplaceItem = {
  id: number;
  name: string;
  category_id: number;
  origin_id?: number;
};

export type PartialMarketplaceItem = Pick<
  MarketplaceItem,
  "name" | "category_id" | "origin_id"
>;
