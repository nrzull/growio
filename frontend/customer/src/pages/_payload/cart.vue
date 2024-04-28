<template>
  <PromiseModal ref="deleteItemModalRef">
    <template #heading>Delete item from cart</template>
    <template #footer="{ resolve, reject }">
      <Button size="md" type="link-neutral" @click="reject"> Cancel </Button>
      <Button size="md" @click="resolve"> Confirm </Button>
    </template>
  </PromiseModal>

  <PageLoader :loading="isLoading" />

  <PageShape>
    <template #heading>
      <slot name="heading"></slot>
    </template>

    <template #subheading>
      <slot name="subheading"></slot>
    </template>

    <Tabs>
      <Button
        size="md"
        type="neutral"
        icon="arrowBack"
        @click="$router.push(`/${payloadKey}/categories`)"
      >
      </Button>
      <Button size="md" type="neutral" active icon="cart">Cart</Button>
    </Tabs>

    <Notification
      v-if="!selectedItems.length"
      :model-value="{ text: 'There is no items in cart', type: 'error' }"
    />
    <template v-else>
      <Table :table headless>
        <template #name="{ ctx }">
          <span
            :class="$style.name"
            @click="
              $router.push(
                `/${payloadKey}/categories/${ctx.row.original.category_id}/items/${ctx.row.original.id}`
              )
            "
          >
            {{ ctx.row.original.name }}
          </span>
        </template>

        <template #price="{ ctx }">
          <template v-if="ctx.row.original.price && ctx.row.original.quantity">
            {{
              formatPrice({
                currency: payload.marketplace.currency,
                price: ctx.row.original.price,
                quantity: ctx.row.original.quantity,
              })
            }}
          </template>
        </template>

        <template #quantity="{ ctx }">
          <template v-if="ctx.row.original.quantity">
            {{ ctx.row.original.quantity }}
          </template>
        </template>

        <template #actions="{ ctx }">
          <Button
            type="neutral"
            size="sm"
            icon="minusCircle"
            @click.stop="decrement(ctx.row.original)"
          ></Button>
          <Button
            type="neutral"
            size="sm"
            icon="plus"
            @click.stop="increment(ctx.row.original)"
          ></Button>
        </template>
      </Table>

      <div :class="$style.radioGroups">
        <div :class="$style.radioGroup">
          <div :class="$style.radioGroupTitle">Оплата</div>
          <Radio option="online" v-model="paymentType">Картой онлайн</Radio>
          <Radio option="in_place" v-model="paymentType">Наличными</Radio>
        </div>

        <div :class="$style.radioGroup">
          <div :class="$style.radioGroupTitle">Способы доставки</div>
          <Radio option="self_export" v-model="deliveryType">Самовывоз</Radio>
          <Radio option="export" v-model="deliveryType">
            Указать адрес доставки
          </Radio>
          <TextInput
            v-if="deliveryType === 'export'"
            placeholder="Адрес"
            v-model="deliveryAddress"
          />
        </div>
      </div>

      <Button :disabled="!hasQuantity" @click="updateOrder">
        Checkout

        <template v-if="totalPrice">
          {{
            formatPrice({
              price: String(totalPrice),
              currency: payload.marketplace.currency,
              quantity: 1,
            })
          }}
        </template>
      </Button>
    </template>
  </PageShape>
</template>

<script setup lang="ts">
import { MarketplaceItem } from "@growio/shared/api/growio/marketplace_items/types";
import { computed, ref } from "vue";
import Tabs from "@growio/shared/components/Tabs.vue";
import Button from "@growio/shared/components/Button.vue";
import Table from "@growio/shared/components/Table.vue";
import {
  createColumnHelper,
  getCoreRowModel,
  useVueTable,
} from "@tanstack/vue-table";
import PromiseModal from "@growio/shared/components/PromiseModal.vue";
import Notification from "@growio/shared/components/Notifications/Notification.vue";
import { useRoute, useRouter } from "vue-router";
import PageShape from "@growio/shared/components/PageShape.vue";
import { formatPrice } from "@growio/shared/utils/money";
import { useCart } from "~/composables/useCart";
import { Wait, wait } from "@growio/shared/composables/wait";
import PageLoader from "@growio/shared/components/PageLoader.vue";
import { differenceWith, equals } from "remeda";
import { getItemDescendants } from "~/utils/category";
import { addErrorNotification } from "@growio/shared/composables/notifications";
import {
  NOTIFICATION_CUSTOMER_PAYLOAD_DIFF,
  NOTIFICATION_CUSTOMER_PAYLOAD_UPDATE_ERROR,
} from "@growio/shared/composables/notifications/constants";
import { apiCustomersUpdateMarketplacePayload } from "@growio/shared/api/growio/customers";
import { payload, getPayload } from "~/composables/payload";
import Radio from "@growio/shared/components/Radio.vue";
import TextInput from "@growio/shared/components/TextInput.vue";

const route = useRoute();
const router = useRouter();
const payloadKey = route.params.payload as string;

const paymentType = ref<"online" | "in_place">("online");
const deliveryType = ref<"export" | "self_export">("self_export");
const deliveryAddress = ref<string>();

const deleteItemModalRef = ref<InstanceType<typeof PromiseModal>>();

const isLoading = computed(() =>
  wait.some([Wait.MARKETPLACE_ORDER_UPDATE, Wait.MARKETPLACE_PAYLOAD_FETCH])
);

const { decrement, hasQuantity, increment, selectedItems, totalPrice } =
  useCart({
    key: payloadKey,
    deleteItemModalRef,
    items: computed(() => payload.value.items),
  });

const columnHelper = createColumnHelper<MarketplaceItem>();

const columns = ref([
  columnHelper.display({ id: "name" }),

  columnHelper.display({
    id: "quantity",
    meta: { style: { "text-align": "right" } },
  }),

  columnHelper.display({
    id: "price",
    meta: { style: { width: "0", "text-align": "right" } },
  }),

  columnHelper.display({ id: "actions", meta: { style: { width: "0" } } }),
]);

const table = useVueTable({
  getCoreRowModel: getCoreRowModel(),

  get data() {
    return selectedItems.value;
  },

  get columns() {
    return columns.value;
  },
});

const updateOrder = async () => {
  try {
    wait.start(Wait.MARKETPLACE_ORDER_UPDATE);

    const newPayload = await getPayload(payloadKey);
    const oldItems = payload.value.items.map(getItemDescendants).flat();
    const freshItems = newPayload.items.map(getItemDescendants).flat();
    const diffItems = differenceWith(oldItems, freshItems, equals);

    const deletedSelectedItems = selectedItems.value.filter(
      (v) => !freshItems.some((vv) => vv.id === v.id)
    );

    selectedItems.value = selectedItems.value
      .filter((v) => !deletedSelectedItems.some((vv) => vv.id === v.id))
      .map((v) => {
        const freshItem = freshItems.find((vv) => vv.id === v.id)!;

        return {
          ...freshItem,
          quantity:
            freshItem.quantity >= v.quantity ? v.quantity : freshItem.quantity,
        };
      })
      .filter((v) => !!v.quantity);

    payload.value.items = newPayload.items;

    if (diffItems.length) {
      addErrorNotification({ text: NOTIFICATION_CUSTOMER_PAYLOAD_DIFF });
      return;
    }

    payload.value = await apiCustomersUpdateMarketplacePayload({
      key: payloadKey,
      payload: {
        items: selectedItems.value,
        status: paymentType.value === "online" ? "need_payment" : "preparing",
        payment_type: paymentType.value,
        delivery_type: deliveryType.value,
        delivery_address: deliveryAddress.value,
      },
    });

    location.reload();
  } catch (e) {
    console.error(e);
    addErrorNotification({ text: NOTIFICATION_CUSTOMER_PAYLOAD_UPDATE_ERROR });
  } finally {
    wait.end(Wait.MARKETPLACE_ORDER_UPDATE);
  }
};
</script>

<style module>
.name {
  cursor: pointer;
}

.radioGroups {
  display: grid;
  gap: 24px;
}

.radioGroup {
  display: grid;
  gap: 8px;
}

.radioGroupTitle {
  font-size: 18px;
  font-weight: 500;
}
</style>
