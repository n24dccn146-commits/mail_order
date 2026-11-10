-- =====================================================
-- MAIL_ORDER database - MySQL 8.x
-- =====================================================
DROP DATABASE IF EXISTS mail_order;
CREATE DATABASE mail_order
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE mail_order;

-- ---------------- EMPLOYEES ----------------
CREATE TABLE employees (
    employees_id  INT          NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    zip_code      VARCHAR(10)  NOT NULL,
    PRIMARY KEY (employees_id)
) ENGINE=InnoDB;

-- ---------------- CUSTOMERS ----------------
CREATE TABLE customers (
    customers_id  INT          NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    zip_code      VARCHAR(10)  NOT NULL,
    PRIMARY KEY (customers_id)
) ENGINE=InnoDB;

-- ---------------- PARTS ----------------
CREATE TABLE parts (
    parts_id           INT           NOT NULL AUTO_INCREMENT,
    part_name          VARCHAR(100)  NOT NULL,
    price              DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    quantity_in_stock  INT           NOT NULL DEFAULT 0 CHECK (quantity_in_stock >= 0),
    PRIMARY KEY (parts_id)
) ENGINE=InnoDB;

-- ---------------- ORDERS ----------------
-- Một khách hàng đặt nhiều đơn; một nhân viên nhận nhiều đơn.
CREATE TABLE orders (
    orders_id           INT   NOT NULL AUTO_INCREMENT,
    customers_id        INT   NOT NULL,
    employees_id        INT   NOT NULL,
    received_date       DATE  NOT NULL,
    expected_ship_date  DATE  NULL,
    actual_ship_date    DATE  NULL,          -- NULL = chưa giao
    PRIMARY KEY (orders_id),
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customers_id) REFERENCES customers (customers_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orders_employees
        FOREIGN KEY (employees_id) REFERENCES employees (employees_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_expected_ship_date CHECK (expected_ship_date IS NULL OR expected_ship_date >= received_date),
    CONSTRAINT chk_actual_ship_date   CHECK (actual_ship_date   IS NULL OR actual_ship_date   >= received_date)
) ENGINE=InnoDB;

-- ---------------- ORDER_DETAILS (quan hệ M:N Orders - Parts) ----------------
CREATE TABLE order_details (
    orders_id  INT NOT NULL,
    parts_id   INT NOT NULL,
    quantity   INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (orders_id, parts_id),
    CONSTRAINT fk_order_details_orders
        FOREIGN KEY (orders_id) REFERENCES orders (orders_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_order_details_parts
        FOREIGN KEY (parts_id) REFERENCES parts (parts_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

USE mail_order;

-- -----------------------------------------------------
-- 1. DỮ LIỆU MẪU CHO BẢNG EMPLOYEES (Nhân viên)
-- -----------------------------------------------------
INSERT INTO employees (employees_id, first_name, last_name, zip_code) VALUES
(1, 'Nguyen', 'Van An', '10000'),
(2, 'Tran', 'Thi Bich', '20000'),
(3, 'Le', 'Hoang Nam', '30000'),
(4, 'Pham', 'Minh Tuan', '40000'),
(5, 'Hoang', 'Thu Ha', '50000');

-- -----------------------------------------------------
-- 2. DỮ LIỆU MẪU CHO BẢNG CUSTOMERS (Khách hàng)
-- -----------------------------------------------------
INSERT INTO customers (customers_id, first_name, last_name, zip_code) VALUES
(1, 'Vu', 'Quang Huy', '70000'),
(2, 'Do', 'Thi Mai', '71000'),
(3, 'Bui', 'Van Cuong', '72000'),
(4, 'Ngo', 'Thanh Nga', '73000'),
(5, 'Dang', 'Ngoc Lan', '74000'),
(6, 'Phan', 'Quoc Bao', '75000');

-- -----------------------------------------------------
-- 3. DỮ LIỆU MẪU CHO BẢNG PARTS (Linh kiện / Phụ tùng)
-- -----------------------------------------------------
INSERT INTO parts (parts_id, part_name, price, quantity_in_stock) VALUES
(1, 'CPU Intel Core i5-13400F', 4500.00, 50),
(2, 'Mainboard B760M Motherboard', 3200.00, 30),
(3, 'RAM 16GB DDR4 3200MHz', 1250.00, 100),
(4, 'SSD NVMe 512GB Gen4', 1400.00, 75),
(5, 'VGA NVIDIA RTX 4060', 8500.00, 20),
(6, 'Power Supply 650W 80 Plus', 1500.00, 40),
(7, 'Case Gaming ATX', 950.00, 25),
(8, 'CPU Cooler Air Fan', 450.00, 60);

-- -----------------------------------------------------
-- 4. DỮ LIỆU MẪU CHO BẢNG ORDERS (Đơn hàng)
-- Lưu ý: 
-- - expected_ship_date và received_date hợp lệ (>= received_date)
-- - actual_ship_date có thể NULL (chưa giao) hoặc có ngày tháng cụ thể
-- -----------------------------------------------------
INSERT INTO orders (orders_id, customers_id, employees_id, received_date, expected_ship_date, actual_ship_date) VALUES
(1, 1, 1, '2026-05-01', '2026-05-03', '2026-05-02'), -- Đã giao
(2, 2, 1, '2026-05-03', '2026-05-05', '2026-05-04'), -- Đã giao
(3, 3, 2, '2026-05-05', '2026-05-08', '2026-05-07'), -- Đã giao
(4, 1, 3, '2026-05-10', '2026-05-12', NULL),         -- Chưa giao
(5, 4, 4, '2026-05-12', '2026-05-15', '2026-05-14'), -- Đã giao
(6, 5, 2, '2026-05-15', '2026-05-18', NULL),         -- Chưa giao
(7, 6, 5, '2026-05-16', '2026-05-20', '2026-05-19'); -- Đã giao

-- -----------------------------------------------------
-- 5. DỮ LIỆU MẪU CHO BẢNG ORDER_DETAILS (Chi tiết đơn hàng)
-- Liên kết đơn hàng (orders) và linh kiện (parts) với số lượng cụ thể
-- -----------------------------------------------------
INSERT INTO order_details (orders_id, parts_id, quantity) VALUES
(1, 1, 1), -- Đơn 1 mua 1 CPU
(1, 2, 1), -- Đơn 1 mua 1 Mainboard
(1, 3, 2), -- Đơn 1 mua 2 RAM

(2, 5, 1), -- Đơn 2 mua 1 VGA
(2, 6, 1), -- Đơn 2 mua 1 Nguồn

(3, 4, 1), -- Đơn 3 mua 1 SSD
(3, 7, 1), -- Đơn 3 mua 1 Case
(3, 8, 1), -- Đơn 3 mua 1 Quạt tản nhiệt

(4, 1, 2), -- Đơn 4 mua 2 CPU
(4, 3, 4), -- Đơn 4 mua 4 RAM

(5, 2, 1), -- Đơn 5 mua 1 Mainboard
(5, 4, 2), -- Đơn 5 mua 2 SSD

(6, 5, 2), -- Đơn 6 mua 2 VGA
(6, 6, 2), -- Đơn 6 mua 2 Nguồn

(7, 3, 1), -- Đơn 7 mua 1 RAM
(7, 8, 1); -- Đơn 7 mua 1 Quạt tản nhiệt

-- Truy vấn toàn bộ bảng orders (Danh sách các đơn hàng cơ bản)
SELECT * 
FROM orders;
-- Truy vấn chi tiết đơn hàng kèm thông tin Khách hàng, Nhân viên 
SELECT 
    o.orders_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    o.received_date,
    o.expected_ship_date,
    o.actual_ship_date
FROM orders o
JOIN customers c ON o.customers_id = c.customers_id
JOIN employees e ON o.employees_id = e.employees_id;

-- Truy vấn toàn diện: Đơn hàng + Khách hàng + Nhân viên + Chi tiết linh kiện mua
SELECT 
    o.orders_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    p.part_name,
    od.quantity,
    p.price AS unit_price,
    (od.quantity * p.price) AS total_price,
    o.received_date,
    o.actual_ship_date
FROM orders o
JOIN customers c ON o.customers_id = c.customers_id
JOIN employees e ON o.employees_id = e.employees_id
JOIN order_details od ON o.orders_id = od.orders_id
JOIN parts p ON od.parts_id = p.parts_id
ORDER BY o.orders_id;