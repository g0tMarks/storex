-- name: ListCustomers :many
SELECT * 
FROM app.customers 
ORDER BY name;

-- name: GetCustomer :one
SELECT * 
FROM app.customers 
WHERE customer_id = $1;

-- name: CreateCustomer :one
INSERT INTO app.customers (name, contact_info, verification_status)
VALUES ($1, $2, $3)
RETURNING *;

-- name: UpdateCustomer :one
UPDATE app.customers
SET name = $2, contact_info = $3, verification_status = $4, is_enabled = $5
WHERE customer_id = $1
RETURNING *;

-- name: DeleteCustomer :exec
DELETE FROM app.customers WHERE customer_id = $1;

-- name: GetCustomerAgreements :many
SELECT a.*
FROM app.customers c
JOIN app.agreements a ON c.customer_id = a.customer_id
WHERE c.customer_id = $1
ORDER BY a.start_date DESC;

-- name: GetCustomerMessages :many
SELECT m.*
FROM app.customers c
JOIN app.messages m ON c.customer_id = m.customer_id
WHERE c.customer_id = $1
ORDER BY m.message_id DESC;
