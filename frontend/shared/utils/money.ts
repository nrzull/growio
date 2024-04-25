const _currencies = ["USD", "RUB", "KGS"] as const;
export type Currency = (typeof _currencies)[number];
export const currencies = _currencies as unknown as string[];

export const formatPrice = (params: {
  price: string;
  currency: string;
  quantity: number;
}) => {
  const preparedNumber = Number(
    (Number(params.price) * params.quantity).toFixed(2)
  );

  return new Intl.NumberFormat("ru-RU", {
    style: "currency",
    currency: params.currency,
  }).format(preparedNumber);
};
