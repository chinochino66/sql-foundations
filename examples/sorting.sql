-- 顧客ID昇順
SELECT * FROM Visits ORDER BY customer_id ASC;

-- 取引金額降順
SELECT * FROM Transactions ORDER BY amount DESC;

-- 取引なし訪問の多い順 → 同数なら顧客ID昇順
SELECT v.customer_id, COUNT(*) AS count_no_trans
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id
WHERE t.visit_id IS NULL
GROUP BY v.customer_id
ORDER BY count_no_trans DESC, v.customer_id ASC
LIMIT 10;
