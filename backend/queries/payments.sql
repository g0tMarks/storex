-- name: ListPayments :many
SELECT * FROM app.payments ORDER BY payment_id DESC;

-- name: GetPayment :one
SELECT * FROM app.payments WHERE payment_id = @payment_id::uuid;

-- name: CreatePayment :one
INSERT INTO app.payments (invoice_id, method, gateway_ref, status)
VALUES (@invoice_id, @method, @gateway_ref, @status::app.payment_status)
RETURNING *;

-- name: UpdatePayment :one
UPDATE app.payments
SET invoice_id = @invoice_id, method = @method, gateway_ref = @gateway_ref, status = @status::app.payment_status
WHERE payment_id = @payment_id::uuid
RETURNING *;

-- name: DeletePayment :exec
DELETE FROM app.payments WHERE payment_id = @payment_id::uuid;
