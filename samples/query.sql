WITH paid_orders AS (
    SELECT
        o.id,
        o.customer_id,
        o.total_amount,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.created_at DESC) AS row_num
    FROM orders AS o
    WHERE o.status IN ('paid', 'shipped')
      AND o.created_at >= DATE '2026-01-01'
)
SELECT
    c.name,
    COUNT(*) AS order_count,
    SUM(p.total_amount) FILTER (WHERE p.row_num <= 10) AS recent_total
FROM paid_orders AS p
JOIN customers AS c ON c.id = p.customer_id
GROUP BY c.name
HAVING COUNT(*) > 0
ORDER BY recent_total DESC NULLS LAST;

