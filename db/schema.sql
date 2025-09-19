-- Storman-like Self-Storage Management Database Schema

CREATE TABLE facilities (
    facility_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    region VARCHAR(100),
    config JSONB
);

CREATE TABLE units (
    unit_id SERIAL PRIMARY KEY,
    facility_id INT NOT NULL REFERENCES facilities(facility_id) ON DELETE CASCADE,
    unit_type VARCHAR(100),
    size VARCHAR(50),
    price DECIMAL(10,2),
    status VARCHAR(50)
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    verification_status VARCHAR(50)
);

CREATE TABLE agreements (
    agreement_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    unit_id INT NOT NULL REFERENCES units(unit_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(50)
);

CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    agreement_id INT NOT NULL REFERENCES agreements(agreement_id) ON DELETE CASCADE,
    due_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    method VARCHAR(50),
    gateway_ref VARCHAR(255),
    status VARCHAR(50)
);

CREATE TABLE access_logs (
    log_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    unit_id INT NOT NULL REFERENCES units(unit_id) ON DELETE CASCADE,
    datetime TIMESTAMP NOT NULL DEFAULT NOW(),
    action VARCHAR(50)
);

CREATE TABLE messages (
    message_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    type VARCHAR(50), -- SMS, Email
    direction VARCHAR(20), -- inbound, outbound
    status VARCHAR(50)
);
