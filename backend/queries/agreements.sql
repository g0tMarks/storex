-- name: ListAgreements :many
SELECT * FROM app.agreements ORDER BY start_date DESC;

-- name: GetAgreement :one
SELECT * FROM app.agreements WHERE agreement_id = @agreement_id::uuid;

-- name: CreateAgreement :one
INSERT INTO app.agreements (
    customer_id,
    unit_id,
    start_date,
    end_date,
    status
) VALUES (
    @customer_id, @unit_id, @start_date, @end_date, @status::app.agreement_status
)
RETURNING *;

-- name: GetAgreementByID :one
SELECT * FROM app.agreements WHERE agreement_id = @agreement_id::uuid;

-- name: ListAgreementsByCustomer :many
SELECT * FROM app.agreements
WHERE customer_id = @customer_id
ORDER BY start_date DESC;

-- name: UpdateAgreementStatus :one
UPDATE app.agreements
SET status = @status::app.agreement_status
WHERE agreement_id = @agreement_id::uuid
RETURNING *;

-- name: DeleteAgreement :exec
DELETE FROM app.agreements
WHERE agreement_id = @agreement_id::uuid;

-- name: GetAgreementInvoices :many
SELECT i.*
FROM app.agreements a
JOIN app.invoices i ON a.agreement_id = i.agreement_id
WHERE a.agreement_id = @agreement_id::uuid
ORDER BY i.due_date DESC;

-- name: GetAgreementCustomer :one
SELECT c.*
FROM app.agreements a
JOIN app.customers c ON a.customer_id = c.customer_id
WHERE a.agreement_id = @agreement_id::uuid;

-- name: GetAgreementUnit :one
SELECT u.*
FROM app.agreements a
JOIN app.units u ON a.unit_id = u.unit_id
WHERE a.agreement_id = @agreement_id::uuid;
