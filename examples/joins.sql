-- INNER JOIN（共通部分）
SELECT v.visit_id, v.customer_id, t.transaction_id, t.amount
FROM Visits v
JOIN Transactions t ON t.visit_id = v.visit_id;

-- LEFT JOIN（左は必ず残す）
SELECT v.visit_id, v.customer_id, t.transaction_id, t.amount
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id;

-- LEFTで“右条件はONへ”（LEFTの実質INNER化を防ぐ）
SELECT v.visit_id
FROM Visits v
LEFT JOIN Transactions t
  ON t.visit_id = v.visit_id
 AND t.amount > 0;

-- 準結合（存在チェック）
SELECT v.visit_id
FROM Visits v
WHERE EXISTS (SELECT 1 FROM Transactions t WHERE t.visit_id = v.visit_id);

-- 反結合（存在しないもの）
SELECT v.visit_id
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id
WHERE t.visit_id IS NULL;
