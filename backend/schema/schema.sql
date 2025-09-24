-- ============================================
-- Core Schema
-- ============================================

CREATE SCHEMA IF NOT EXISTS app;

-- Represents the customer account / entity (business or individual)

CREATE TABLE app.customers (
    customer_id bigserial PRIMARY KEY,
    customer_name text NOT NULL,
    created_at timestamp NOT NULL DEFAULT now(),
    is_enabled boolean NOT NULL DEFAULT true
);

-- Represents individual people linked to a customer

CREATE TABLE app.contacts (
    contact_id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    first_name text,
    last_name text,
    email text,
    phone_mobile text,
    phone_home text,
    phone_work text,
    role text, -- e.g. primary, billing, emergency
    is_primary boolean DEFAULT false
);

CREATE INDEX idx_contacts_customer_id ON app.contacts(customer_id);

-- Allows multiple addresses per customer (billing, street, etc.)

CREATE TABLE app.customer_addresses (
    address_id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    type text NOT NULL, -- billing, street
    line1 text,
    suburb text,
    city text,
    state text,
    postcode text,
    country text,
    latitude numeric,
    longitude numeric
);

CREATE INDEX idx_addresses_customer_id ON app.customer_addresses(customer_id);

-- Access control info for gates/doors

CREATE TABLE app.customer_access (
    access_id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    pin text,
    always_allowed boolean DEFAULT false,
    time_zone text
);

CREATE INDEX idx_access_customer_id ON app.customer_access(customer_id);

-- Flexible attributes to extend customer info

CREATE TABLE app.customer_custom_fields (
    field_id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    field_name text NOT NULL,
    field_value text
);

CREATE INDEX idx_customfields_customer_id ON app.customer_custom_fields(customer_id);

-- ============================================
-- Operational Tables
-- ============================================

-- Facilities
CREATE TABLE app.facilities (
    facility_id bigserial PRIMARY KEY,
    name text NOT NULL,
    address text,
    region text,
    config jsonb NOT NULL DEFAULT '{}'::jsonb
);

-- Units
CREATE TABLE app.units (
    unit_id bigserial PRIMARY KEY,
    facility_id bigint NOT NULL REFERENCES app.facilities(facility_id) ON DELETE CASCADE,
    unit_type text,
    size text,
    price numeric(10,2),
    status text
);

CREATE INDEX idx_units_facility_id ON app.units(facility_id);

-- Agreements
CREATE TABLE app.agreements (
    agreement_id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    unit_id bigint NOT NULL REFERENCES app.units(unit_id) ON DELETE CASCADE,
    start_date date NOT NULL,
    end_date date,
    status text
);

-- Ensure only one active agreement per unit
CREATE UNIQUE INDEX uq_active_agreement_per_unit
    ON app.agreements(unit_id)
    WHERE status = 'active';

CREATE INDEX idx_agreements_customer_id ON app.agreements(customer_id);
CREATE INDEX idx_agreements_unit_id ON app.agreements(unit_id);

-- Invoices
CREATE TABLE app.invoices (
    invoice_id bigserial PRIMARY KEY,
    agreement_id bigint NOT NULL REFERENCES app.agreements(agreement_id) ON DELETE CASCADE,
    due_date date NOT NULL,
    amount numeric(10,2) NOT NULL,
    status text
);

CREATE INDEX idx_invoices_agreement_id ON app.invoices(agreement_id);

-- Payments
CREATE TABLE app.payments (
    payment_id bigserial PRIMARY KEY,
    invoice_id bigint NOT NULL REFERENCES app.invoices(invoice_id) ON DELETE CASCADE,
    method text,
    gateway_ref text,
    status text
);

CREATE INDEX idx_payments_invoice_id ON app.payments(invoice_id);

-- Access Logs
CREATE TABLE app.access_logs (
    log_id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    unit_id bigint NOT NULL REFERENCES app.units(unit_id) ON DELETE CASCADE,
    datetime timestamp NOT NULL DEFAULT now(),
    action text
);

CREATE INDEX idx_accesslogs_customer_id ON app.access_logs(customer_id);
CREATE INDEX idx_accesslogs_unit_id ON app.access_logs(unit_id);

-- Messages
CREATE TABLE app.messages (
    message_id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    type text,  -- SMS, Email
    direction text,  -- inbound, outbound
    status text
);

CREATE INDEX idx_messages_customer_id ON app.messages(customer_id);
