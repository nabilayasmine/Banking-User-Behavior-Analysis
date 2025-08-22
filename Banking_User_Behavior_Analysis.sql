--- =================================
---  STEP 1: DATABASE & SCHEMA SETUP 
--- =================================

CREATE DATABASE mandiri_test;
CREATE SCHEMA mtest;


--- ==================================
---  STEP 2: TRANSACTIONS TABLE SETUP
--- ==================================

CREATE TABLE mtest.transactions (
    id BIGINT PRIMARY KEY,
    date TIMESTAMP,
    client_id INT,
    card_id INT,
    amount TEXT,
    use_chip VARCHAR(50),
    merchant_id INT,
    merchant_city VARCHAR(100),
    merchant_state VARCHAR(50),
    zip VARCHAR(20),
    mcc INT,
    errors VARCHAR(200)
);

--- import transactions data
COPY mtest.transactions 
FROM 'C:/Program Files/PostgreSQL/17/data/mandiri/transactions_data.csv' 
DELIMITER ',' CSV HEADER;

--- clean and convert the amount column
ALTER TABLE mtest.transactions 
ALTER COLUMN amount TYPE NUMERIC(10,2) 
USING REPLACE(amount, '$', '')::NUMERIC(10,2);


--- ============================
---  STEP 3: USERS TABLE SETUP
--- ============================

CREATE TABLE mtest.users (
    id INT PRIMARY KEY,
    current_age INT,
    retirement_age INT,
    birth_year INT,
    birth_month INT,
    gender VARCHAR(10),
    address TEXT,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    per_capita_income TEXT,
    yearly_income TEXT,
    total_debt TEXT,
    credit_score INT,
    num_credit_cards INT
);

--- import users data
COPY mtest.users
FROM 'C:/Program Files/PostgreSQL/17/data/mandiri/users_data.csv' 
DELIMITER ',' CSV HEADER;

--- clean and convert financial columns
ALTER TABLE mtest.users
ALTER COLUMN per_capita_income TYPE NUMERIC(12,2) USING REPLACE(per_capita_income, '$', '')::NUMERIC(12,2),
ALTER COLUMN yearly_income TYPE NUMERIC(12,2) USING REPLACE(yearly_income, '$', '')::NUMERIC(12,2),
ALTER COLUMN total_debt TYPE NUMERIC(12,2) USING REPLACE(total_debt, '$', '')::NUMERIC(12,2);

--- ===========================
---  STEP 4: CARDS TABLE SETUP
--- ===========================

CREATE TABLE mtest.cards (
    id INT PRIMARY KEY,
    client_id INT REFERENCES mtest.users(id),
    card_brand VARCHAR(50),
    card_type VARCHAR(50),
    card_number VARCHAR(20),
    expires VARCHAR(10),
    cvv VARCHAR(5),
    has_chip VARCHAR(5),
    num_cards_issued INT,
    credit_limit TEXT,
    acct_open_date VARCHAR(10),
    year_pin_last_changed INT,
    card_on_dark_web VARCHAR(5)
);

--- import cards data
COPY mtest.cards
FROM 'C:/Program Files/PostgreSQL/17/data/mandiri/cards_data.csv' 
DELIMITER ',' CSV HEADER;

--- clean and convert credit limit column
ALTER TABLE mtest.cards
ALTER COLUMN credit_limit TYPE NUMERIC(10,2) 
USING REPLACE(credit_limit, '$', '')::NUMERIC(10,2);


--- ======================================
--- STEP 5: FOREIGN KEY CONSTRAINTS SETUP
--- ======================================

--- add relationship between transactions and users
ALTER TABLE mtest.transactions
ADD CONSTRAINT fk_transactions_users
FOREIGN KEY (client_id) REFERENCES mtest.users(id);

--- add relationship between transactions and cards
ALTER TABLE mtest.transactions
ADD CONSTRAINT fk_transactions_cards
FOREIGN KEY (card_id) REFERENCES mtest.cards(id);

--- =========================================
---  STEP 6: EXPLORATION DATA ANALYSIS (EDA)
--- =========================================

-- ========================
--  Transactions Table EDA
-- ========================

-- Count total number of records
SELECT COUNT(*) AS total_records
FROM mtest.transactions;

-- Check for NULL values in key columns
SELECT 
    SUM(CASE WHEN client_id IS NULL THEN 1 ELSE 0 END) AS null_client_id,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date
FROM mtest.transactions;

-- Transaction date range (earliest and latest transaction)
SELECT 
    MIN(date) AS first_date,
    MAX(date) AS last_date
FROM mtest.transactions;

-- Basic statistics for transaction amount
SELECT 
    COUNT(*) AS total_tx,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount,
    MIN(amount) AS min_amount,
    MAX(amount) AS max_amount
FROM mtest.transactions;

-- Top 10 spenders by total transaction amount
SELECT 
    client_id,
    COUNT(*) AS tx_count,
    SUM(amount) AS total_spent
FROM mtest.transactions
GROUP BY client_id
ORDER BY total_spent DESC
LIMIT 10;

-- Daily transaction trend
SELECT 
    DATE(date) AS tx_date,
    COUNT(*) AS daily_tx,
    SUM(amount) AS daily_amount
FROM mtest.transactions
GROUP BY DATE(date)
ORDER BY tx_date;

-- Monthly transaction trend
SELECT 
    DATE_TRUNC('month', date)::DATE AS month,
    COUNT(*) AS monthly_tx,
    SUM(amount) AS monthly_amount
FROM mtest.transactions
GROUP BY month
ORDER BY month;

-- Average frequency and spending per user
SELECT 
    client_id,
    COUNT(*) AS freq,
    SUM(amount) AS total_spent,
    AVG(amount) AS avg_amount
FROM mtest.transactions
GROUP BY client_id
ORDER BY freq DESC;

-- Segmentation: one-time vs repeat users
SELECT 
    CASE WHEN tx_count = 1 THEN 'One-time' ELSE 'Repeat' END AS user_type,
    COUNT(*) AS user_count
FROM (
    SELECT client_id, COUNT(*) AS tx_count
    FROM mtest.transactions
    GROUP BY client_id
) t
GROUP BY user_type;

-- Spending segmentation: low, medium, high spenders
SELECT 
    client_id,
    SUM(amount) AS total_spent,
    CASE 
        WHEN SUM(amount) < 100 THEN 'Low spender'
        WHEN SUM(amount) BETWEEN 100 AND 500 THEN 'Mid spender'
        ELSE 'High spender'
    END AS segment
FROM mtest.transactions
GROUP BY client_id;

-- =================
--  Users Table EDA
-- =================

-- Count total users
SELECT COUNT(DISTINCT id) AS total_users
FROM mtest.users;

-- Distribution by gender
SELECT gender, COUNT(*) AS user_count
FROM mtest.users
GROUP BY gender;

-- Age statistics
SELECT 
    MIN(current_age) AS min_age,
    MAX(current_age) AS max_age,
    AVG(current_age) AS avg_age
FROM mtest.users;

-- Age distribution by category
SELECT 
    CASE 
        WHEN current_age < 20 THEN 'Teen'
        WHEN current_age BETWEEN 20 AND 30 THEN 'Young Adult'
        WHEN current_age BETWEEN 31 AND 45 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    COUNT(*) AS user_count
FROM mtest.users
GROUP BY age_group
ORDER BY age_group;

-- ==================
--  Cards Table EDA
-- ==================

-- Number of cards per user
SELECT 
    client_id,
    COUNT(*) AS card_count
FROM mtest.cards
GROUP BY client_id
ORDER BY card_count DESC;

-- Most frequently used card type
SELECT 
    card_type,
    COUNT(*) AS card_count
FROM mtest.cards
GROUP BY card_type
ORDER BY card_count DESC;

-- ================
--  All Table EDA
-- ================

-- Transaction volume and amount by gender
SELECT 
    u.gender,
    COUNT(t.id) AS total_transactions,
    SUM(t.amount) AS total_amount
FROM mtest.transactions t
JOIN mtest.users u ON t.client_id = u.id
GROUP BY u.gender;

-- Transaction volume and amount by age group
SELECT 
    CASE 
        WHEN u.current_age < 20 THEN 'Teen'
        WHEN u.current_age BETWEEN 20 AND 30 THEN 'Young Adult'
        WHEN u.current_age BETWEEN 31 AND 45 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    COUNT(t.id) AS total_tx,
    SUM(t.amount) AS total_amount
FROM mtest.transactions t
JOIN mtest.users u ON t.client_id = u.id
GROUP BY age_group
ORDER BY age_group;

-- Transaction analysis by card type
SELECT 
    c.card_type,
    COUNT(t.id) AS total_transactions,
    SUM(t.amount) AS total_amount
FROM mtest.transactions t
JOIN mtest.cards c ON t.card_id = c.id
GROUP BY c.card_type
ORDER BY total_amount DESC;

-- =========================================
--  STEP 7: DYNAMIC DASHBOARD QUERIES
-- =========================================

SELECT
    t.id AS transaction_id,
    t.date,
    DATE_TRUNC('day', t.date) AS transaction_day,
    DATE_PART('hour', t.date) AS transaction_hour,
    t.amount,
    t.merchant_city,
    u.id AS user_id,
    u.gender,
    u.current_age,
    u.yearly_income,
    u.credit_score,
    c.id AS card_id,
    c.card_brand,
    c.card_type,
    c.credit_limit
FROM mtest.transactions t
LEFT JOIN mtest.users u ON t.client_id = u.id
LEFT JOIN mtest.cards c ON t.card_id = c.id
WHERE t.date >= '2019-07-01';

