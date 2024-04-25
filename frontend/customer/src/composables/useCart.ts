import { MarketplaceTreeItem } from "@growio/shared/api/growio/marketplace_items_tree/types";
import { useLocalStorage } from "@vueuse/core";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import { Ref, computed } from "vue";

export const useCart = (params: {
  key: string;
  deleteItemModalRef?: Ref<InstanceType<typeof PromiseModal>>;
}) => {
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
    const foundItem = selectedItems.value.find((i) => i.id === item.id);

    if (foundItem) {
      foundItem.quantity += 1;
    } else {
      addItem(item);
    }
  };

  const decrement = async (item: MarketplaceTreeItem) => {
    const foundItem = selectedItems.value.find((i) => i.id === item.id);

    if (foundItem && foundItem.quantity >= 2) {
      foundItem.quantity -= 1;
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
    if (isSelected(item)) {
      return;
    }

    selectedItems.value.push({ ...item, quantity: 1 });
  };

  const removeItem = (item: MarketplaceTreeItem) => {
    if (!isSelected(item)) {
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
