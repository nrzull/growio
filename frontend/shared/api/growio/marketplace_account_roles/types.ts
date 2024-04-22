export type MarketplaceAccountRole = {
  id: number;
  name: string;
  description: string;
  priority: number;
  permissions?: string[];
};

export type PartialMarketplaceAccountRole = Pick<
  MarketplaceAccountRole,
  "name" | "description" | "permissions"
>;
