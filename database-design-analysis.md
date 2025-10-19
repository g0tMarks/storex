# Database Design Analysis: Storage Management System

## Overview

This document analyzes the database design patterns and principles demonstrated in a storage management system (StoreX) built with PostgreSQL. The system manages storage facilities, units, customers, agreements, and billing operations.

## Table of Contents

1. [Schema Organization](#schema-organization)
2. [Data Types and Constraints](#data-types-and-constraints)
3. [Relationship Patterns](#relationship-patterns)
4. [Indexing Strategy](#indexing-strategy)
5. [Code Generation Integration](#code-generation-integration)
6. [Business Logic Constraints](#business-logic-constraints)
7. [Performance Considerations](#performance-considerations)
8. [Key Design Principles](#key-design-principles)

## Schema Organization

### 1. Namespace Separation
```sql
CREATE SCHEMA IF NOT EXISTS app;
```
- **Principle**: Use schemas to logically separate application data
- **Benefit**: Prevents naming conflicts and provides clear organization
- **Pattern**: All tables are prefixed with `app.` namespace

### 2. Logical Grouping
The schema is organized into two main sections:

#### Core Schema (Customer Management)
- `customers` - Primary customer entities
- `contacts` - Customer contact information
- `customer_addresses` - Multiple addresses per customer
- `customer_access` - Access control (PINs, timezones)
- `customer_custom_fields` - Flexible key-value storage

#### Operational Schema (Business Operations)
- `facilities` - Storage locations
- `units` - Individual storage units
- `agreements` - Rental contracts
- `invoices` - Billing records
- `payments` - Payment transactions
- `access_logs` - Audit trail
- `messages` - Communication records

## Data Types and Constraints

### 1. UUID Primary Keys
```sql
customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
```
- **Pattern**: All entities use UUID primary keys
- **Benefits**: 
  - Globally unique identifiers
  - No collision risk in distributed systems
  - Better security (non-sequential)
- **Implementation**: Uses PostgreSQL's `uuid-ossp` extension

### 2. Custom ENUM Types
```sql
CREATE TYPE app.unit_status AS ENUM ('available', 'reserved', 'occupied', 'maintenance');
CREATE TYPE app.agreement_status AS ENUM ('active', 'terminated', 'expired', 'pending');
CREATE TYPE app.invoice_status AS ENUM ('unpaid', 'paid', 'overdue', 'cancelled');
```
- **Principle**: Use ENUMs for controlled vocabularies
- **Benefits**: 
  - Data integrity at database level
  - Clear business rules
  - Type safety in application code

### 3. Flexible Data Storage
```sql
config JSONB NOT NULL  -- For facility configuration
```
- **Pattern**: Use JSONB for semi-structured data
- **Benefits**: 
  - Flexible schema evolution
  - Efficient storage and querying
  - Maintains relational benefits

### 4. Nullable vs Non-Nullable Fields
```sql
customer_name TEXT NOT NULL,        -- Required
first_name TEXT,                    -- Optional
email TEXT UNIQUE,                  -- Optional but unique when present
```
- **Principle**: Explicit nullability design
- **Pattern**: Core business fields are NOT NULL, optional fields are nullable

## Relationship Patterns

### 1. Hierarchical Customer Data
```
customers (1) → (N) contacts
customers (1) → (N) customer_addresses  
customers (1) → (N) customer_access
customers (1) → (N) customer_custom_fields
```
- **Pattern**: One-to-many relationships with CASCADE DELETE
- **Benefit**: Maintains data integrity when customers are removed

### 2. Business Process Flow
```
customers (1) → (N) agreements (N) ← (1) units
agreements (1) → (N) invoices (N) ← (1) payments
```
- **Pattern**: Clear business process modeling
- **Benefit**: Tracks complete customer journey

### 3. Audit and Logging
```sql
customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE SET NULL,
unit_id UUID NOT NULL REFERENCES app.units(unit_id) ON DELETE SET NULL,
```
- **Pattern**: Use SET NULL for audit tables
- **Benefit**: Preserves historical data even when referenced entities are deleted

## Indexing Strategy

### 1. Foreign Key Indexes
```sql
CREATE INDEX IF NOT EXISTS idx_contacts_customer_id ON app.contacts(customer_id);
CREATE INDEX IF NOT EXISTS idx_agreements_customer_id ON app.agreements(customer_id);
```
- **Principle**: Index all foreign keys
- **Benefit**: Optimizes JOIN operations and referential integrity checks

### 2. Business Query Optimization
```sql
CREATE INDEX IF NOT EXISTS idx_access_logs_datetime ON app.access_logs(datetime);
```
- **Pattern**: Index frequently queried columns
- **Benefit**: Optimizes time-based queries

### 3. Unique Constraints for Business Rules
```sql
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_agreement_per_unit
    ON app.agreements(unit_id)
    WHERE status = 'active';
```
- **Pattern**: Partial unique indexes for business constraints
- **Benefit**: Enforces "one active agreement per unit" rule

## Code Generation Integration

### 1. SQLC Configuration
The `sqlc.yaml` demonstrates modern database tooling:

```yaml
version: "2"
sql:
  - engine: "postgresql"
    schema: "./schema/schema.sql"
    queries: "./queries"
    gen:
      go:
        package: "db"
        out: "./internal/db"
        emit_db_tags: true
        emit_json_tags: true
        json_tags_case_style: "camel"
```

### 2. Type Safety
```yaml
overrides:
- db_type: "app.unit_status"
  go_type:
    type: "AppUnitStatus"
```
- **Pattern**: Custom type mapping for ENUMs
- **Benefit**: Type-safe Go code generation

### 3. Query Organization
- **Pattern**: Separate `.sql` files per entity
- **Structure**: Each file contains CRUD operations
- **Naming**: Consistent `:one`, `:many`, `:exec` annotations

## Business Logic Constraints

### 1. Referential Integrity
```sql
REFERENCES app.customers(customer_id) ON DELETE CASCADE
REFERENCES app.units(unit_id) ON DELETE CASCADE
```
- **Pattern**: CASCADE for dependent data, SET NULL for audit data
- **Benefit**: Maintains data consistency

### 2. Business Rules Enforcement
```sql
-- Ensure only one active agreement per unit
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_agreement_per_unit
    ON app.agreements(unit_id)
    WHERE status = 'active';
```
- **Pattern**: Database-level business rule enforcement
- **Benefit**: Prevents invalid states regardless of application logic

### 3. Default Values
```sql
status app.unit_status DEFAULT 'available'
is_enabled BOOLEAN NOT NULL DEFAULT true
created_at TIMESTAMP NOT NULL DEFAULT now()
```
- **Pattern**: Sensible defaults for common scenarios
- **Benefit**: Reduces application complexity

## Performance Considerations

### 1. Partitioning Readiness
```sql
-- Access logs (partitioning candidate)
CREATE TABLE IF NOT EXISTS app.access_logs (
```
- **Pattern**: Design tables with partitioning in mind
- **Benefit**: Easy scaling for high-volume audit data

### 2. Efficient Data Types
```sql
amount NUMERIC(10,2) NOT NULL
price NUMERIC(10,2)
```
- **Pattern**: Use appropriate precision for monetary values
- **Benefit**: Avoids floating-point precision issues

### 3. Strategic Indexing
- Foreign key indexes for JOINs
- Time-based indexes for audit queries
- Unique indexes for business constraints

## Key Design Principles

### 1. **Separation of Concerns**
- Core customer data separate from operational data
- Clear boundaries between different business domains

### 2. **Data Integrity First**
- Database-level constraints over application-level validation
- Proper foreign key relationships with appropriate CASCADE rules

### 3. **Flexibility and Extensibility**
- JSONB for configuration data
- Custom fields table for additional attributes
- ENUM types for controlled vocabularies

### 4. **Audit and Compliance**
- Comprehensive logging with `access_logs`
- Soft deletes with `is_enabled` flags
- Timestamp tracking with `created_at`

### 5. **Performance by Design**
- Strategic indexing from the start
- Partitioning considerations for high-volume tables
- Efficient data types and constraints

### 6. **Developer Experience**
- Code generation with SQLC
- Type-safe generated models
- Consistent naming conventions
- Clear query organization

## Lessons Learned

1. **Start with Business Rules**: The schema clearly models the storage rental business process
2. **Plan for Scale**: Partitioning candidates and indexing strategy show forward thinking
3. **Type Safety Matters**: ENUM types and code generation provide compile-time safety
4. **Audit Everything**: Comprehensive logging is built into the design
5. **Flexibility Through Structure**: JSONB and custom fields provide extensibility without schema changes
6. **Tooling Integration**: Modern tools like SQLC improve developer productivity and code quality

This database design demonstrates a mature approach to building scalable, maintainable, and type-safe database schemas for business applications.
