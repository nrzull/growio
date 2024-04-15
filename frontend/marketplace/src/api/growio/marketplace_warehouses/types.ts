export type MarketplaceWarehouse = {
  id: number;
  name: string;
  address?: string;
};

export type PartialMarketplaceWarehouse = Pick<
  MarketplaceWarehouse,
  "name" | "address"
>;
