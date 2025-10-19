
-- =====================================================
-- Core Schema
-- =====================================================

CREATE SCHEMA IF NOT EXISTS app;

-- ENUMs
CREATE TYPE app.unit_status AS ENUM ('available', 'reserved', 'occupied', 'maintenance');
CREATE TYPE app.agreement_status AS ENUM ('active', 'terminated', 'expired', 'pending');
CREATE TYPE app.invoice_status AS ENUM ('unpaid', 'paid', 'overdue', 'cancelled');
CREATE TYPE app.payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE app.message_type AS ENUM ('sms', 'email', 'system');
CREATE TYPE app.message_direction AS ENUM ('inbound', 'outbound');
CREATE TYPE app.message_status AS ENUM ('queued', 'sent', 'delivered', 'failed');

--Add UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Customers
CREATE TABLE IF NOT EXISTS app.customers (

    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_name TEXT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT now(),

    is_enabled BOOLEAN NOT NULL DEFAULT true
);nd)

-- Contacts
CREATE TABLE IF NOT EXISTS app.contacts (

    contact_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,

    first_name TEXT,

    last_name TEXT,

    email TEXT UNIQUE,

    phone_mobile TEXT,

    phone_home TEXT,

    phone_work TEXT,

    role TEXT,

    is_primary BOOLEAN DEFAULT false
);
CREATE INDEX IF NOT EXISTS idx_contacts_customer_id ON app.contacts(customer_id);

-- Customer addresses
CREATE TABLE IF NOT EXISTS app.customer_addresses (

    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,

    type TEXT NOT NULL,

    line1 TEXT,

    suburb TEXT,

    city TEXT,

    state TEXT,

    postcode TEXT,

    country TEXT,

    latitude NUMERIC,

    longitude NUMERIC
);
CREATE INDEX IF NOT EXISTS idx_addresses_customer_id ON app.customer_addresses(customer_id);

-- Customer access (PINs, timezones)
CREATE TABLE IF NOT EXISTS app.customer_access (

    access_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,

    pin TEXT,

    always_allowed BOOLEAN DEFAULT false,

    time_zone TEXT
);
CREATE INDEX IF NOT EXISTS idx_access_customer_id ON app.customer_access(customer_id);

-- Custom fields (flexible key/value)
CREATE TABLE IF NOT EXISTS app.customer_custom_fields (

    field_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,

    field_name TEXT NOT NULL,

    field_value TEXT
);
CREATE INDEX IF NOT EXISTS idx_custom_fields_customer_id ON app.customer_custom_fields(customer_id);

-- =====================================================
-- Operational Tables
-- =====================================================

-- Facilities
CREATE TABLE IF NOT EXISTS app.facilities (

    facility_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name TEXT NOT NULL,

    address TEXT,

    region TEXT,

    config JSONB NOT NULL
);

-- Units
CREATE TABLE IF NOT EXISTS app.units (

    unit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    facility_id UUID NOT NULL REFERENCES app.facilities(facility_id) ON DELETE CASCADE,

    unit_type TEXT,

    size TEXT,

    price NUMERIC(10,2),

    status app.unit_status DEFAULT 'available'
);
CREATE INDEX IF NOT EXISTS idx_units_facility_id ON app.units(facility_id);

-- Agreements
CREATE TABLE IF NOT EXISTS app.agreements (

    agreement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,

    unit_id UUID NOT NULL REFERENCES app.units(unit_id) ON DELETE CASCADE,

    start_date DATE NOT NULL,

    end_date DATE,

    status app.agreement_status DEFAULT 'active'
);

-- Ensure only one active agreement per unit
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_agreement_per_unit
    ON app.agreements(unit_id)
    WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_agreements_customer_id ON app.agreements(customer_id);
CREATE INDEX IF NOT EXISTS idx_agreements_unit_id ON app.agreements(unit_id);

-- Invoices
CREATE TABLE IF NOT EXISTS app.invoices (

    invoice_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    agreement_id UUID NOT NULL REFERENCES app.agreements(agreement_id) ON DELETE CASCADE,

    due_date DATE NOT NULL,

    amount NUMERIC(10,2) NOT NULL,

    status app.invoice_status DEFAULT 'unpaid'
);
CREATE INDEX IF NOT EXISTS idx_invoices_agreement_id ON app.invoices(agreement_id);

-- Payments
CREATE TABLE IF NOT EXISTS app.payments (

    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    invoice_id UUID NOT NULL REFERENCES app.invoices(invoice_id) ON DELETE CASCADE,

    method TEXT,

    gateway_ref TEXT,

    status app.payment_status DEFAULT 'pending'
);
CREATE INDEX IF NOT EXISTS idx_payments_invoice_id ON app.payments(invoice_id);


-- Access logs (partitioning candidate)
CREATE TABLE IF NOT EXISTS app.access_logs (

    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE SET NULL,

    unit_id UUID NOT NULL REFERENCES app.units(unit_id) ON DELETE SET NULL,

    datetime TIMESTAMP NOT NULL DEFAULT now(),

    action TEXT
);
CREATE INDEX IF NOT EXISTS idx_access_logs_customer_id ON app.access_logs(customer_id);
CREATE INDEX IF NOT EXISTS idx_access_logs_datetime ON app.access_logs(datetime);
CREATE INDEX IF NOT EXISTS idx_access_logs_unit_id ON app.access_logs(unit_id);

-- Messages
DO $$ BEGIN
    CREATE TYPE app.message_type AS ENUM ('sms', 'email', 'system');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE app.message_direction AS ENUM ('inbound', 'outbound');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE app.message_status AS ENUM ('queued', 'sent', 'delivered', 'failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS app.messages (

    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,

    type app.message_type,

    direction app.message_direction,

    status app.message_status DEFAULT 'queued'
);
CREATE INDEX IF NOT EXISTS idx_messages_customer_id ON app.messages(customer_id);
