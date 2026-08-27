import React, { useMemo, useReducer, useRef } from "react";
import type { ReactNode } from "react";

const VERSION = "1.0.0";
const API_URL = new URL("/api/orders", process.env.PUBLIC_URL ?? "https://example.test");
const moneyPattern = /^(?<currency>USD|BRL)\s+(?<amount>\d+(?:\.\d{2})?)$/iu;

interface Loadable<T> {
  readonly data: T[];
  readonly loading: boolean;
  readonly error?: Error;
}

type OrderStatus = "draft" | "paid" | "shipped" | "cancelled";

class OrderDashboard extends React.PureComponent<{ title: string }, Loadable<OrderStatus>> {
  static defaultProps = { title: "Orders" };
  #privateCounter = 0;

  override render(): ReactNode {
    const { title } = this.props;
    return <section data-testid="dashboard"><h1>{title}</h1></section>;
  }
}

function useOrderState(initialStatus: OrderStatus = "draft") {
  const themeSearchInputRef = useRef<HTMLInputElement | null>(null);
  const [state, updateState] = useReducer(
    (data: Loadable<OrderStatus>, partialData: Partial<Loadable<OrderStatus>>) => ({
      ...data,
      ...partialData,
    }),
    { data: [initialStatus], loading: false }
  );

  const total = useMemo(() => state.data.length + 0b1010 + 0o17 + 0xff, [state.data]);
  const optional = themeSearchInputRef.current?.value ?? "";

  for (const status of state.data) {
    console.log(`${VERSION}:${status}:${optional}`, API_URL.pathname, moneyPattern.test("BRL 10.00"));
  }

  return { state, updateState, total, themeSearchInputRef };
}

export { OrderDashboard, useOrderState };

