export type MarketplaceMarket = {
  id: number;
  address: string;
};

export type PartialMarketplaceMarket = Pick<MarketplaceMarket, "address">;
