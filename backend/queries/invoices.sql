-- name: ListInvoices :many
SELECT * FROM app.invoices ORDER BY invoice_id DESC;

-- name: GetInvoice :one
SELECT * FROM app.invoices WHERE invoice_id = @invoice_id::uuid;

-- name: CreateInvoice :one
INSERT INTO app.invoices (agreement_id, due_date, amount, status)
VALUES (@agreement_id, @due_date, @amount, @status::app.invoice_status)
RETURNING *;

-- name: UpdateInvoice :one
UPDATE app.invoices
SET agreement_id = @agreement_id, due_date = @due_date, amount = @amount, status = @status::app.invoice_status
WHERE invoice_id = @invoice_id::uuid
RETURNING *;

-- name: DeleteInvoice :exec
DELETE FROM app.invoices WHERE invoice_id = @invoice_id::uuid;
