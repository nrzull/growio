export type AccountRaw = { id: number; email: string };

export type MarketplaceAccountRaw = {
  id: number;
  marketplace: MarketplaceRaw;
  role: MarketplaceAccountRole;
};

export type MarketplaceRaw = {
  id: number;
  name: string;
};

export type MarketplaceAccountRole = {};
