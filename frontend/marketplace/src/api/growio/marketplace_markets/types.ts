export type MarketplaceMarket = {
  id: number;
  name: string;
  address?: string;
};

export type PartialMarketplaceMarket = Pick<
  MarketplaceMarket,
  "name" | "address"
>;
