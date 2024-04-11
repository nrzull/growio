import { MarketplaceItemAsset } from "~/api/growio/marketplace_item_assets/types";

export type DropzoneFile = Pick<File, "name" | "type"> & {
  src: string;
  origin: File | MarketplaceItemAsset;
};
