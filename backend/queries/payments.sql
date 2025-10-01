-- name: ListPayments :many
SELECT * FROM app.payments ORDER BY payment_id DESC;

-- name: GetPayment :one
SELECT * FROM app.payments WHERE payment_id = $1;

-- name: CreatePayment :one
INSERT INTO app.payments (invoice_id, method, gateway_ref, status)
VALUES ($1, $2, $3, $4::app.payment_status)
RETURNING *;

-- name: UpdatePayment :one
UPDATE app.payments
SET invoice_id = $2, method = $3, gateway_ref = $4::app.payment_status, status = $5::app.payment_status
WHERE payment_id = $1
RETURNING *;

-- name: DeletePayment :exec
DELETE FROM app.payments WHERE payment_id = $1;
