import { DropzoneFile } from "@growio/shared/components/Dropzone/types";
import { isPlainObject } from "remeda";
import { reactive } from "vue";
import { isMarketplaceItemAsset } from "@growio/shared/api/growio/marketplace_item_assets/utils";
import {
  MarketplaceItemAsset,
  PartialMarketplaceItemAsset,
} from "@growio/shared/api/growio/marketplace_item_assets/types";

export const isDropzoneFile = (v: unknown): v is DropzoneFile =>
  isPlainObject(v) && ["src", "type"].every((key) => key in v);

export const intoDropzoneFile = (
  v: File | DropzoneFile | MarketplaceItemAsset
): DropzoneFile => {
  if (isDropzoneFile(v)) {
    return v;
  }

  const base = reactive({ type: "", name: "", src: "", origin: v });

  if (isMarketplaceItemAsset(v)) {
    base.type = v.mimetype;
    base.src = v.src;
  } else {
    base.type = v.type;
    base.name = v.name;
    const reader = new FileReader();
    reader.onload = () => (base.src = reader.result as string);
    reader.readAsDataURL(v);
  }

  return base;
};

export const fromDropzoneFile = (
  v: DropzoneFile
): PartialMarketplaceItemAsset | MarketplaceItemAsset => ({
  id: isMarketplaceItemAsset(v.origin) ? v.origin.id : undefined,
  mimetype: v.type,
  src: v.src,
});
