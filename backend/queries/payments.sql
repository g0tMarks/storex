-- name: ListPayments :many
SELECT * FROM app.payments ORDER BY payment_id DESC;

-- name: GetPayment :one
SELECT * FROM app.payments WHERE payment_id = $1;

-- name: CreatePayment :one
INSERT INTO app.payments (invoice_id, method, gateway_ref, status)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: UpdatePayment :one
UPDATE app.payments
SET invoice_id = $2, method = $3, gateway_ref = $4, status = $5
WHERE payment_id = $1
RETURNING *;

-- name: DeletePayment :exec
DELETE FROM app.payments WHERE payment_id = $1;
