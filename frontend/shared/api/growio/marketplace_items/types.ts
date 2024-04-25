export type MarketplaceItem = {
  id: number;
  name: string;
  description?: string;
  infinity?: boolean;
  quantity?: number;
  category_id: number;
  origin_id?: number;
  price?: string;
};

export type PartialMarketplaceItem = Pick<
  MarketplaceItem,
  | "name"
  | "category_id"
  | "origin_id"
  | "description"
  | "infinity"
  | "quantity"
  | "price"
>;
