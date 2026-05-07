-- ============================================================
-- AUTO PARTS DATABASE SCHEMA (PostgreSQL)
-- ============================================================

-- Drop tables in reverse dependency order (if they exist)
DROP TABLE IF EXISTS quotes CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS purchase_items CASCADE;
DROP TABLE IF EXISTS purchases CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================
-- TABLE: users
-- Stores both Admin and Client accounts
-- ============================================================
CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(255) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    phone       VARCHAR(30),
    role        VARCHAR(10)  NOT NULL CHECK (role IN ('ADMIN', 'CLIENT'))
);

CREATE INDEX idx_users_email ON users(email);

-- ============================================================
-- TABLE: categories
-- Product categories (e.g. Brakes, Engine, Electrical)
-- ============================================================
CREATE TABLE categories (
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- TABLE: suppliers
-- Companies that supply us with parts
-- ============================================================
CREATE TABLE suppliers (
    id           BIGSERIAL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL,
    contact_info TEXT
);

-- ============================================================
-- TABLE: products
-- Automotive parts / articles in the catalog
-- ============================================================
CREATE TABLE products (
    id             BIGSERIAL PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    description    TEXT,
    price          DECIMAL(12, 3) NOT NULL,  -- Price in TND (Tunisian Dinar)
    stock_quantity INTEGER        NOT NULL DEFAULT 0,
    image_url      VARCHAR(500),
    category_id    BIGINT REFERENCES categories(id) ON DELETE SET NULL
);

CREATE INDEX idx_products_category ON products(category_id);

-- ============================================================
-- TABLE: purchases
-- Stock replenishment orders placed with suppliers
-- ============================================================
CREATE TABLE purchases (
    id            BIGSERIAL PRIMARY KEY,
    supplier_id   BIGINT REFERENCES suppliers(id) ON DELETE SET NULL,
    total_cost    DECIMAL(12, 3),
    purchase_date TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_purchases_supplier ON purchases(supplier_id);
CREATE INDEX idx_purchases_date     ON purchases(purchase_date);

-- ============================================================
-- TABLE: purchase_items
-- Individual line items within a purchase
-- ============================================================
CREATE TABLE purchase_items (
    id          BIGSERIAL PRIMARY KEY,
    purchase_id BIGINT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
    product_id  BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity    INTEGER        NOT NULL,
    unit_cost   DECIMAL(12, 3) NOT NULL
);

CREATE INDEX idx_purchase_items_purchase ON purchase_items(purchase_id);
CREATE INDEX idx_purchase_items_product  ON purchase_items(product_id);

-- ============================================================
-- TABLE: orders
-- Customer sales orders (Cash on Delivery)
-- ============================================================
CREATE TABLE orders (
    id           BIGSERIAL PRIMARY KEY,
    client_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    total_amount DECIMAL(12, 3) NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                     CHECK (status IN ('PENDING', 'CONFIRMED', 'DELIVERED', 'CANCELLED')),
    order_date   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_client ON orders(client_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date   ON orders(order_date);

-- ============================================================
-- TABLE: order_items
-- Individual line items within a customer order
-- ============================================================
CREATE TABLE order_items (
    id         BIGSERIAL PRIMARY KEY,
    order_id   BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity   INTEGER        NOT NULL,
    unit_price DECIMAL(12, 3) NOT NULL
);

CREATE INDEX idx_order_items_order   ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ============================================================
-- TABLE: quotes (devis)
-- Quote requests submitted by clients
-- ============================================================
CREATE TABLE quotes (
    id           BIGSERIAL PRIMARY KEY,
    client_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message      TEXT,
    status       VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                     CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    request_date TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quotes_client ON quotes(client_id);
CREATE INDEX idx_quotes_status ON quotes(status);

-- ============================================================
-- SEED DATA: Default Admin User
-- Password: admin123  (BCrypt encoded)
-- ============================================================
INSERT INTO users (email, password, first_name, last_name, phone, role)
VALUES (
    'admin@autoparts.tn',
    '$2a$10$3KZ7MuC7l8gTHJk0gHPLBe7GTVJOq22kJMlfXmAOPm2dLMOoSXGRe',
    'Admin',
    'AutoParts',
    '+216 00 000 000',
    'ADMIN'
);

-- Sample Categories
INSERT INTO categories (name) VALUES
    ('Moteur'),
    ('Freinage'),
    ('Suspension'),
    ('Électrique'),
    ('Carrosserie'),
    ('Transmission'),
    ('Filtration'),
    ('Refroidissement');

-- Sample Suppliers
INSERT INTO suppliers (name, contact_info) VALUES
    ('PartsPro TN',     'contact@partspro.tn | +216 71 000 001'),
    ('AutoStock Tunis', 'stock@autostock.tn | +216 71 000 002'),
    ('MedAuto Sfax',    'info@medauto.tn    | +216 74 000 003');

-- ============================================================
-- USEFUL ANALYTICS QUERIES (for Dashboard API)
-- ============================================================

-- Daily Revenue
-- SELECT DATE(order_date) AS day, SUM(total_amount) AS revenue
-- FROM orders
-- WHERE status != 'CANCELLED'
-- GROUP BY day
-- ORDER BY day DESC;

-- Top 10 Sold Products
-- SELECT p.name, SUM(oi.quantity) AS total_sold
-- FROM order_items oi
-- JOIN products p ON p.id = oi.product_id
-- JOIN orders o ON o.id = oi.order_id
-- WHERE o.status != 'CANCELLED'
-- GROUP BY p.id, p.name
-- ORDER BY total_sold DESC
-- LIMIT 10;

-- Total Revenue This Month
-- SELECT SUM(total_amount) AS monthly_revenue
-- FROM orders
-- WHERE status != 'CANCELLED'
--   AND DATE_TRUNC('month', order_date) = DATE_TRUNC('month', NOW());
