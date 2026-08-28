from __future__ import annotations

import dataclasses
import functools
import re
from typing import Generic, Iterable, TypeVar

T = TypeVar("T")
MONEY_RE = re.compile(r"^(?P<currency>USD|BRL)\s+(?P<amount>\d+(?:\.\d{2})?)$")

count = True

@dataclasses.dataclass(slots=True, frozen=True)
class Order(Generic[T]):
    id: int
    status: str
    payload: T | None = None


def traced(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        print(f"calling {fn.__name__}", args, kwargs)
        return fn(*args, **kwargs)

    return wrapper


@traced
def summarize(orders: Iterable[Order[dict[str, object]]]) -> dict[str, int]:
    """Exercise strings, decorators, parameters, type names, numbers and magic vars."""
    counts: dict[str, int] = {}
    for index, order in enumerate(orders, start=1):
        counts[order.status] = counts.get(order.status, 0) + index
    return counts


if __name__ == "__main__":
    print(summarize([Order(1, "paid", {"amount": 10.5})]))
    print(MONEY_RE.match("BRL 19.90") is not None)

