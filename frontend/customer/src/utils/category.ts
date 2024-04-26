import { isMarketplaceItem } from "@growio/shared/api/growio/marketplace_items/utils";
import {
  MarketplaceItemsTree,
  MarketplaceTreeCategory,
  MarketplaceTreeItem,
} from "@growio/shared/api/growio/marketplace_items_tree/types";
import { isMarketplaceTreeItemCategory } from "@growio/shared/api/growio/marketplace_items_tree/utils";

export const buildFindCategory =
  (defaultItems: () => MarketplaceItemsTree) => (id: number) => {
    const executor = (children = defaultItems()): MarketplaceTreeCategory[] => {
      const r = children
        .filter(isMarketplaceTreeItemCategory)
        .map((v) => (v.id === id ? v : executor(v.children)));

      return r.flat();
    };

    const [foundCategory] = executor().filter((v) => v);
    return foundCategory;
  };

export const buildFindItem =
  (defaultItems: () => MarketplaceItemsTree) => (id: number) => {
    const executor = (children = defaultItems()): MarketplaceTreeItem[] => {
      const r = children.map((v) =>
        isMarketplaceTreeItemCategory(v)
          ? executor(v.children)
          : v.id === id
          ? v
          : undefined
      );

      return r.flat();
    };

    const [foundItem] = executor().filter((v) => v);
    return foundItem;
  };

export const getCategoryAncestors = (params: {
  categoryId: number;
  findCategory: (id: number) => MarketplaceTreeCategory;
}) => {
  if (!params.categoryId) {
    return [];
  }

  const category = params.findCategory(params.categoryId);

  const ancestors = [];

  const executor = (parent = category) => {
    const target = params.findCategory(parent?.parent_id);

    if (target) {
      ancestors.unshift(target);
      executor(target);
    }
  };

  executor();

  return ancestors.concat(category);
};

export const getItemDescendants = (category: MarketplaceTreeCategory) => {
  const itemDescendants: MarketplaceTreeItem[] = [];

  const executor = (target = category) => {
    target.children.map((c) => {
      if (isMarketplaceItem(c)) {
        itemDescendants.push(c);
      } else {
        executor(c);
      }
    });
  };

  executor();

  return itemDescendants;
};
