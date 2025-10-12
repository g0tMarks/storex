-- name: ListCustomers :many
SELECT * FROM app.customers ORDER BY customer_name;

-- name: GetCustomer :one
SELECT * FROM app.customers WHERE customer_id = $1::uuid;

-- name: CreateCustomer :one
INSERT INTO app.customers (customer_name)
VALUES ($1)
RETURNING *;

-- name: UpdateCustomer :one
UPDATE app.customers
SET customer_name = $2, is_enabled = $3
WHERE customer_id = $1::uuid;
RETURNING *;

-- name: DeleteCustomer :exec
DELETE FROM app.customers WHERE customer_id = $1::uuid;