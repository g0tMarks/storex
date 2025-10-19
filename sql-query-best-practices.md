# SQL Query Best Practices & Learnings

## Overview
This document captures key learnings and best practices for writing SQL queries, derived from analyzing a production codebase that uses SQLC for type-safe code generation with PostgreSQL.

## 1. Code Generation with SQLC

### Benefits
- **Type Safety**: Compile-time validation of SQL queries against database schema
- **No ORM Overhead**: Direct SQL with generated Go structs
- **Performance**: No runtime reflection or query building overhead
- **Maintainability**: Schema changes automatically update generated code

### Configuration
```yaml
# sqlc.yaml
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

## 2. Query Organization & Structure

### File Organization
- **One file per entity**: Each table gets its own `.sql` file
- **Consistent naming**: `customers.sql`, `agreements.sql`, `invoices.sql`
- **Logical grouping**: Related queries stay together

### Query Naming Conventions
```sql
-- CRUD Operations
-- name: ListCustomers :many
-- name: GetCustomer :one
-- name: CreateCustomer :one
-- name: UpdateCustomer :one
-- name: DeleteCustomer :exec

-- Filtered Queries
-- name: GetCustomersByStatus :many
-- name: ListAgreementsByCustomer :many

-- Relationship Queries
-- name: GetAgreementInvoices :many
-- name: GetAgreementCustomer :one
```

### Return Type Annotations
- `:many` - Returns multiple rows (slice)
- `:one` - Returns single row (struct)
- `:exec` - No return value (execution only)

## 3. Parameter Binding & Type Safety

### Parameter Syntax
```sql
-- Use @ prefix for parameters
-- name: GetCustomer :one
SELECT * FROM app.customers WHERE customer_id = @customer_id::uuid;

-- Type casting is essential
-- name: CreateAgreement :one
INSERT INTO app.agreements (status) 
VALUES (@status::app.agreement_status);
```

### Best Practices
- **Always cast parameters**: `@id::uuid`, `@status::app.status_type`
- **Consistent naming**: Use descriptive parameter names
- **Type validation**: SQLC validates parameter types against schema

## 4. Schema Design Patterns

### Primary Keys
```sql
-- Use UUIDs for all primary keys
CREATE TABLE app.customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- other fields...
);
```

### Foreign Key Relationships
```sql
-- Proper cascade relationships
CREATE TABLE app.agreements (
    agreement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES app.customers(customer_id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES app.units(unit_id) ON DELETE CASCADE
);
```

### Custom Types (ENUMs)
```sql
-- Define custom types for status fields
CREATE TYPE app.unit_status AS ENUM ('available', 'reserved', 'occupied', 'maintenance');
CREATE TYPE app.agreement_status AS ENUM ('active', 'terminated', 'expired', 'pending');

-- Use in table definitions
CREATE TABLE app.units (
    status app.unit_status DEFAULT 'available'
);
```

### Strategic Indexing
```sql
-- Index foreign keys
CREATE INDEX IF NOT EXISTS idx_agreements_customer_id ON app.agreements(customer_id);
CREATE INDEX IF NOT EXISTS idx_agreements_unit_id ON app.agreements(unit_id);

-- Index frequently queried columns
CREATE INDEX IF NOT EXISTS idx_access_logs_datetime ON app.access_logs(datetime);
```

## 5. Query Patterns & Best Practices

### CRUD Operations
```sql
-- List (with ordering)
-- name: ListCustomers :many
SELECT * FROM app.customers ORDER BY customer_name;

-- Get by ID
-- name: GetCustomer :one
SELECT * FROM app.customers WHERE customer_id = @customer_id::uuid;

-- Create (with RETURNING)
-- name: CreateCustomer :one
INSERT INTO app.customers (customer_name)
VALUES (@customer_name)
RETURNING *;

-- Update (with RETURNING)
-- name: UpdateCustomer :one
UPDATE app.customers
SET customer_name = @customer_name, is_enabled = @is_enabled
WHERE customer_id = @customer_id::uuid
RETURNING *;

-- Delete
-- name: DeleteCustomer :exec
DELETE FROM app.customers WHERE customer_id = @customer_id::uuid;
```

### Filtered Queries
```sql
-- Filter by foreign key
-- name: ListAgreementsByCustomer :many
SELECT * FROM app.agreements
WHERE customer_id = @customer_id
ORDER BY start_date DESC;

-- Filter by status
-- name: GetUnitsByStatus :many
SELECT * FROM app.units
WHERE status = @status::app.unit_status
ORDER BY unit_id;
```

### Join Queries
```sql
-- Get related data through joins
-- name: GetAgreementInvoices :many
SELECT i.*
FROM app.agreements a
JOIN app.invoices i ON a.agreement_id = i.agreement_id
WHERE a.agreement_id = @agreement_id::uuid
ORDER BY i.due_date DESC;

-- Get related entity
-- name: GetAgreementCustomer :one
SELECT c.*
FROM app.agreements a
JOIN app.customers c ON a.customer_id = c.customer_id
WHERE a.agreement_id = @agreement_id::uuid;
```

## 6. Generated Code Patterns

### Struct Generation
```go
// Generated struct with proper tags
type AppCustomer struct {
    CustomerID   uuid.UUID `db:"customer_id" json:"customerId"`
    CustomerName string    `db:"customer_name" json:"customerName"`
    CreatedAt    time.Time `db:"created_at" json:"createdAt"`
    IsEnabled    bool      `db:"is_enabled" json:"isEnabled"`
}
```

### Enum Type Generation
```go
// Custom enum types with proper methods
type AppUnitStatus string

const (
    AppUnitStatusAvailable   AppUnitStatus = "available"
    AppUnitStatusReserved    AppUnitStatus = "reserved"
    AppUnitStatusOccupied    AppUnitStatus = "occupied"
    AppUnitStatusMaintenance AppUnitStatus = "maintenance"
)

// Scanner and Valuer interfaces for database integration
func (e *AppUnitStatus) Scan(src interface{}) error { /* ... */ }
func (e AppUnitStatus) Value() (driver.Value, error) { /* ... */ }
```

### Null Handling
```go
// Null types for nullable fields
type NullAppUnitStatus struct {
    AppUnitStatus AppUnitStatus `json:"appUnitStatus"`
    Valid         bool          `json:"valid"`
}
```

## 7. Performance Considerations

### Query Optimization
- **Use indexes strategically**: Foreign keys and frequently filtered columns
- **Keep queries simple**: Avoid unnecessary complexity
- **Use appropriate JOINs**: Explicit JOINs over subqueries when possible
- **Consider partitioning**: For high-volume tables (e.g., access logs)

### Indexing Strategy
```sql
-- Foreign key indexes (essential)
CREATE INDEX idx_agreements_customer_id ON app.agreements(customer_id);

-- Query filter indexes
CREATE INDEX idx_access_logs_datetime ON app.access_logs(datetime);

-- Unique constraints with conditions
CREATE UNIQUE INDEX uq_active_agreement_per_unit
    ON app.agreements(unit_id)
    WHERE status = 'active';
```

## 8. Error Handling & Validation

### Type Safety
- SQLC provides compile-time validation
- Parameter types must match schema
- Generated code handles type conversions

### Null Handling
- Use `sql.NullString`, `sql.NullTime` for nullable fields
- Generated null types for custom enums
- Proper validation in application layer

## 9. Migration & Schema Management

### Schema Versioning
- Multiple schema versions (V1, V2)
- Clear migration path
- ERD documentation for visual reference

### Schema Evolution
```sql
-- Safe schema changes
CREATE TABLE IF NOT EXISTS app.customers (
    -- fields...
);

-- Add indexes safely
CREATE INDEX IF NOT EXISTS idx_customers_name ON app.customers(customer_name);
```

## 10. Testing & Maintenance

### Query Testing
- Test generated functions with real data
- Validate parameter binding
- Check return type correctness

### Code Generation Workflow
1. Write SQL queries in `.sql` files
2. Run `sqlc generate` to update Go code
3. Update application code to use new functions
4. Test with database integration

## 11. Common Pitfalls to Avoid

### Parameter Issues
```sql
-- ❌ Missing type casting
WHERE id = @id

-- ✅ Proper type casting
WHERE id = @id::uuid
```

### Return Type Mismatches
```sql
-- ❌ Wrong return type for single row
-- name: GetCustomer :many
SELECT * FROM customers WHERE id = @id;

-- ✅ Correct return type
-- name: GetCustomer :one
SELECT * FROM customers WHERE id = @id;
```

### Missing Indexes
```sql
-- ❌ No index on frequently queried column
SELECT * FROM orders WHERE customer_id = @customer_id;

-- ✅ Add index
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

## 12. Advanced Patterns

### Complex Joins
```sql
-- Multi-table joins with proper aliasing
-- name: GetCustomerWithAgreements :one
SELECT 
    c.*,
    a.agreement_id,
    a.start_date,
    a.status as agreement_status
FROM app.customers c
LEFT JOIN app.agreements a ON c.customer_id = a.customer_id
WHERE c.customer_id = @customer_id::uuid;
```

### Conditional Queries
```sql
-- Use WHERE clauses for filtering
-- name: GetActiveAgreements :many
SELECT * FROM app.agreements
WHERE status = 'active'
ORDER BY start_date DESC;
```

## Conclusion

These patterns provide a robust foundation for writing maintainable, type-safe SQL queries that integrate well with Go applications. The key is consistency, proper type handling, and strategic use of database features like indexes and constraints.

The SQLC approach eliminates many common SQL-related bugs while maintaining the performance benefits of direct SQL queries.
