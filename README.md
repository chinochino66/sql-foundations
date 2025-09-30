# SQL Foundations – 到達メモ

**学習到達範囲**  
`SELECT` / `WHERE` / `JOIN` / `INNER` / `LEFT` / `GROUP BY` / `HAVING` / `Sorting`

本メモは LeetCode SQL（特に **1581. Customer Who Visited but Did Not Make Any Transactions**）を中心に、SQL基礎を学んだ内容と「そのまま使える型（クエリ例）」をまとめたもの。

---

## 0. メンタルモデル
- SQLは「行の集合」を操作する言語。
- `WHERE` → 集計前に行を絞る  
- `GROUP BY` → 同じ値を持つ行をまとめる  
- `HAVING` → 集計後に絞る  
- `ORDER BY` → 最終的に並べ替える  
- JOINで行が増える現象を**ファンアウト**と呼ぶ。粒度ズレには要注意。

---

## 1. SELECT / WHERE
```sql
-- 顧客ごとの訪問レコード
SELECT visit_id, customer_id
FROM Visits
WHERE customer_id = 54;
````

---

## 2. JOIN（INNER / LEFT）

```sql
-- INNER JOIN：共通部分だけ（両テーブルに一致がある行のみ）
SELECT v.visit_id, v.customer_id, t.transaction_id, t.amount
FROM Visits v
INNER JOIN Transactions t
  ON t.visit_id = v.visit_id;

-- LEFT JOIN：左テーブル（Visits）を必ず残す。無ければ右側は NULL。
SELECT v.visit_id, v.customer_id, t.transaction_id, t.amount
FROM Visits v
LEFT JOIN Transactions t
  ON t.visit_id = v.visit_id;
```

### LEFTの落とし穴（実質INNER化）

```sql
-- ❌ NG: WHERE に右テーブル列条件を書くと NULL が落ちる
SELECT v.visit_id
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id
WHERE t.amount > 0;

-- ✅ OK: 右テーブルの条件は ON に寄せる
SELECT v.visit_id
FROM Visits v
LEFT JOIN Transactions t
  ON t.visit_id = v.visit_id
 AND t.amount > 0;
```

---

## 3. 反結合（Anti-Join）と準結合（Semi-Join）

### 反結合（存在しないものを取る）

```sql
-- A) LEFT ... IS NULL
SELECT v.customer_id, COUNT(*) AS count_no_trans
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id
WHERE t.visit_id IS NULL
GROUP BY v.customer_id;

-- B) NOT EXISTS
SELECT v.customer_id, COUNT(*) AS count_no_trans
FROM Visits v
WHERE NOT EXISTS (
  SELECT 1
  FROM Transactions t
  WHERE t.visit_id = v.visit_id
)
GROUP BY v.customer_id;
```

### 準結合（存在するかだけ）

```sql
-- 取引が1件以上ある訪問
SELECT v.visit_id
FROM Visits v
WHERE EXISTS (
  SELECT 1 FROM Transactions t WHERE t.visit_id = v.visit_id
);
```

---

## 4. GROUP BY / HAVING

```sql
-- 顧客ごとの訪問回数
SELECT customer_id, COUNT(*) AS visit_count
FROM Visits
GROUP BY customer_id;

-- 訪問2回以上の顧客
SELECT customer_id, COUNT(*) AS visit_count
FROM Visits
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

### ファンアウト対策

```sql
-- 注文明細までJOINしても件数が狂わないように DISTINCT を使う
SELECT v.customer_id, COUNT(DISTINCT v.visit_id) AS visit_cnt
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id
GROUP BY v.customer_id;
```

---

## 5. Sorting（ORDER BY）

```sql
-- 取引なし訪問の多い順、同数なら顧客ID昇順
SELECT v.customer_id, COUNT(*) AS count_no_trans
FROM Visits v
LEFT JOIN Transactions t ON t.visit_id = v.visit_id
WHERE t.visit_id IS NULL
GROUP BY v.customer_id
ORDER BY count_no_trans DESC, v.customer_id ASC
LIMIT 10;
```

### ポイント

* `ORDER BY` は SELECT の最後に書く。
* 別名（AS count_no_trans）は ORDER BY でそのまま使える。
* 上位N件は `LIMIT N`（MySQL/SQLite/Postgres）、`TOP N`（SQL Server）。
* NULLの並びはDBごとに違う。MySQL系では `(col IS NULL)` を追加して制御するのが定番。

---

## 6. チートシート（決め手の型）

* **右条件は ON に書く**（LEFT JOIN の死守）
* **無い** → `LEFT ... IS NULL` / `NOT EXISTS`
* **ある** → `EXISTS` / `IN`
* **粒度ズレ対策** → `COUNT(DISTINCT ...)` または前集計してからJOIN
* 並べ替えは `ORDER BY`; 上位N件は `LIMIT`（環境依存でTOP/FETCH）
