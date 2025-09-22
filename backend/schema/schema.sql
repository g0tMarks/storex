-- Create schema for the app
CREATE SCHEMA IF NOT EXISTS app;

-- ************************************** app.facilities

CREATE TABLE app.facilities
(
    facility_id bigserial NOT NULL,
    name        text NOT NULL,
    address     text,
    region      text,
    config      jsonb NOT NULL DEFAULT '{}'::jsonb,
    CONSTRAINT pk_facilities PRIMARY KEY (facility_id)
);

-- ************************************** app.units

CREATE TABLE app.units
(
    unit_id     bigserial NOT NULL,
    facility_id bigserial NOT NULL,
    unit_type   text,
    size        text,
    price       numeric(10,2),
    status      text,
    CONSTRAINT pk_units PRIMARY KEY (unit_id),
    CONSTRAINT fk_units_facility FOREIGN KEY (facility_id)
        REFERENCES app.facilities(facility_id)
);

CREATE INDEX idx_units_facility_id ON app.units(facility_id);

-- ************************************** app.customers

CREATE TABLE app.customers
(
    customer_id          bigserial NOT NULL,
    name                 text NOT NULL,
    contact_info         text,
    verification_status  text,
    created_at           timestamp NOT NULL DEFAULT NOW(),
    is_enabled           boolean NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

-- ************************************** app.agreements

CREATE TABLE app.agreements
(
    agreement_id bigserial NOT NULL,
    customer_id  bigserial NOT NULL,
    unit_id      bigserial NOT NULL,
    start_date   date NOT NULL,
    end_date     date,
    status       text,
    CONSTRAINT pk_agreements PRIMARY KEY (agreement_id),
    CONSTRAINT fk_agreements_customer FOREIGN KEY (customer_id)
        REFERENCES app.customers(customer_id),
    CONSTRAINT fk_agreements_unit FOREIGN KEY (unit_id)
        REFERENCES app.units(unit_id)
);

-- One active agreement per unit
CREATE UNIQUE INDEX uq_active_agreement_per_unit
    ON app.agreements(unit_id)
    WHERE status = 'active';

CREATE INDEX idx_agreements_customer_id ON app.agreements(customer_id);
CREATE INDEX idx_agreements_unit_id ON app.agreements(unit_id);

-- ************************************** app.invoices

CREATE TABLE app.invoices
(
    invoice_id   bigserial NOT NULL,
    agreement_id bigserial NOT NULL,
    due_date     date NOT NULL,
    amount       numeric(10,2) NOT NULL,
    status       text,
    CONSTRAINT pk_invoices PRIMARY KEY (invoice_id),
    CONSTRAINT fk_invoices_agreement FOREIGN KEY (agreement_id)
        REFERENCES app.agreements(agreement_id)
);

CREATE INDEX idx_invoices_agreement_id ON app.invoices(agreement_id);

-- ************************************** app.payments

CREATE TABLE app.payments
(
    payment_id  bigserial NOT NULL,
    invoice_id  bigserial NOT NULL,
    method      text,
    gateway_ref text,
    status      text,
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_id)
        REFERENCES app.invoices(invoice_id)
);

CREATE INDEX idx_payments_invoice_id ON app.payments(invoice_id);

-- ************************************** app.access_logs

CREATE TABLE app.access_logs
(
    log_id      bigserial NOT NULL,
    customer_id bigserial NOT NULL,
    unit_id     bigserial NOT NULL,
    datetime    timestamp NOT NULL DEFAULT NOW(),
    action      text,
    CONSTRAINT pk_access_logs PRIMARY KEY (log_id),
    CONSTRAINT fk_accesslogs_customer FOREIGN KEY (customer_id)
        REFERENCES app.customers(customer_id),
    CONSTRAINT fk_accesslogs_unit FOREIGN KEY (unit_id)
        REFERENCES app.units(unit_id)
);

CREATE INDEX idx_accesslogs_customer_id ON app.access_logs(customer_id);
CREATE INDEX idx_accesslogs_unit_id ON app.access_logs(unit_id);

-- ************************************** app.messages

CREATE TABLE app.messages
(
    message_id  bigserial NOT NULL,
    customer_id bigserial NOT NULL,
    type        text,  -- SMS, Email
    direction   text,  -- inbound, outbound
    status      text,
    CONSTRAINT pk_messages PRIMARY KEY (message_id),
    CONSTRAINT fk_messages_customer FOREIGN KEY (customer_id)
        REFERENCES app.customers(customer_id)
);

CREATE INDEX idx_messages_customer_id ON app.messages(customer_id);
