# You are using MYSQL
-- =====================================
-- 1. Create Database and Use It
-- =====================================
GRANT ALL PRIVILEGES ON *.* TO 'ri_db'@'localhost';
FLUSH PRIVILEGES;

CREATE DATABASE ecommerce;
USE ecommerce;

-- =====================================
-- 2. Create Tables
-- =====================================

-- Customers table
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    address VARCHAR(255)
);

-- Products table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    description TEXT
);

-- Orders table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- =====================================
-- 3. Insert Sample Data
-- =====================================

-- Insert customers
INSERT INTO customers (name, email, address)
VALUES 
('Alice Johnson', 'alice@example.com', '123 Maple St'),
('Bob Smith', 'bob@example.com', '456 Oak Ave'),
('Carol White', 'carol@example.com', '789 Pine Rd');

-- Insert products
INSERT INTO products (name, price, description)
VALUES 
('Product A', 30.00, 'First product'),
('Product B', 50.00, 'Second product'),
('Product C', 40.00, 'Third product');

-- Insert orders
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES
(1, CURDATE() - INTERVAL 5 DAY, 80.00),
(2, CURDATE() - INTERVAL 20 DAY, 60.00),
(1, CURDATE() - INTERVAL 35 DAY, 120.00),
(3, CURDATE() - INTERVAL 10 DAY, 160.00);

-- =====================================
-- 4. Required Queries
-- =====================================

-- a) Customers who placed orders in the last 30 days
SELECT DISTINCT c.*
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY;

-- b) Total amount of all orders by each customer
SELECT c.name, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- c) Update the price of Product C to 45.00
UPDATE products
SET price = 45.00
WHERE name = 'Product C';

-- d) Add a discount column to the products table
ALTER TABLE products
ADD COLUMN discount DECIMAL(5,2) DEFAULT 0.00;

-- e) Top 3 products with the highest price
SELECT *
FROM products
ORDER BY price DESC
LIMIT 3;

-- g) Join orders and customers to retrieve customer name and order date
SELECT c.name AS customer_name, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- h) Orders with total amount greater than 150.00
SELECT *
FROM orders
WHERE total_amount > 150.00;

-- =====================================
-- 5. Normalize: Add Order Items Table
-- =====================================

-- Create order_items table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity)
VALUES
(1, 1, 2),  -- 2 x Product A
(1, 2, 1),  -- 1 x Product B
(2, 1, 1),  -- 1 x Product A
(3, 3, 3),  -- 3 x Product C
(4, 2, 1),  -- 1 x Product B
(4, 3, 1);  -- 1 x Product C

-- f) Names of customers who have ordered Product A
SELECT DISTINCT c.name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE p.name = 'Product A';

-- i) Average total of all orders
SELECT AVG(total_amount) AS average_order_total
FROM orders;
