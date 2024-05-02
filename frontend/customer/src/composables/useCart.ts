import {
  MarketplaceItemsTree,
  MarketplaceTreeItem,
} from "@growio/shared/api/growio/marketplace_items_tree/types";
import { useLocalStorage } from "@vueuse/core";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import { ComputedRef, Ref, computed } from "vue";
import { buildFindItem } from "~/utils/category";

export const useCart = (params: {
  key: string;
  deleteItemModalRef?: Ref<InstanceType<typeof PromiseModal>>;
  items: ComputedRef<MarketplaceItemsTree>;
}) => {
  const findItem = buildFindItem(() => params.items.value);
  const selectedItems = useLocalStorage<MarketplaceTreeItem[]>(params.key, []);

  const hasQuantity = computed(() =>
    selectedItems.value.some((v) => v.quantity)
  );

  const totalPrice = computed(() =>
    hasQuantity.value
      ? selectedItems.value.reduce(
          (acc, value) => acc + Number(value.price) * value.quantity!,
          0
        )
      : 0
  );

  const increment = (item: MarketplaceTreeItem) => {
    const sourceItem = findItem(item.id);
    const selectedItem = selectedItems.value.find((i) => i.id === item.id);

    if (
      selectedItem &&
      (selectedItem.quantity + 1 <= sourceItem.quantity || sourceItem.infinity)
    ) {
      selectedItem.quantity += 1;
    } else {
      addItem(item);
    }
  };

  const decrement = async (item: MarketplaceTreeItem) => {
    const selectedItem = selectedItems.value.find((i) => i.id === item.id);

    if (selectedItem && selectedItem.quantity >= 2) {
      selectedItem.quantity -= 1;
      return;
    }

    try {
      await params.deleteItemModalRef?.value?.confirm();
    } catch {
      return;
    }

    removeItem(item);
  };

  const isSelected = (item: MarketplaceTreeItem) =>
    selectedItems.value.some((v) => v.id === item.id);

  const getSelected = (item: MarketplaceTreeItem) =>
    selectedItems.value.find((v) => v.id === item.id);

  const addItem = (item: MarketplaceTreeItem) => {
    const sourceItem = findItem(item.id);

    if (
      isSelected(sourceItem) ||
      (!sourceItem.infinity && sourceItem.quantity < 1)
    ) {
      return;
    }

    selectedItems.value.push({ ...item, quantity: 1 });
  };

  const removeItem = (item: MarketplaceTreeItem) => {
    const sourceItem = findItem(item.id);

    if (!isSelected(sourceItem)) {
      return;
    }

    selectedItems.value = selectedItems.value.filter((v) => v.id !== item.id);
  };

  return {
    selectedItems,
    isSelected,
    addItem,
    removeItem,
    increment,
    decrement,
    hasQuantity,
    totalPrice,
    getSelected,
  };
};
