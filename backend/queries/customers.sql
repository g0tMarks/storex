-- name: ListCustomers :many
SELECT * FROM app.customers ORDER BY customer_name;

-- name: GetCustomer :one
SELECT * FROM app.customers WHERE customer_id = @customer_id::uuid;

-- name: CreateCustomer :one
INSERT INTO app.customers (customer_name)
VALUES (@customer_name)
RETURNING *;

-- name: UpdateCustomer :one
UPDATE app.customers
SET customer_name = @customer_name, is_enabled = @is_enabled
WHERE customer_id = @customer_id::uuid
RETURNING *;

-- name: DeleteCustomer :exec
DELETE FROM app.customers WHERE customer_id = @customer_id::uuid;