-- 顧客ごとの訪問回数
SELECT customer_id, COUNT(*) AS visit_count
FROM Visits
GROUP BY customer_id;

-- 訪問2回以上の顧客
SELECT customer_id, COUNT(*) AS visit_count
FROM Visits
GROUP BY customer_id
HAVING COUNT(*) >= 2;

-- 取引なし訪問が2回以上の顧客
SELECT v.customer_id, COUNT(*) AS count_no_trans
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id
WHERE t.visit_id IS NULL
GROUP BY v.customer_id
HAVING COUNT(*) >= 2;
