-- name: ListAccessLogs :many
SELECT * FROM app.access_logs ORDER BY datetime DESC;

-- name: GetAccessLogsByCustomer :many
SELECT * FROM app.access_logs WHERE customer_id = @customer_id ORDER BY datetime DESC;

-- name: GetAccessLogsByUnit :many
SELECT * FROM app.access_logs WHERE unit_id = @unit_id ORDER BY datetime DESC;

-- name: CreateAccessLog :one
INSERT INTO app.access_logs (customer_id, unit_id, datetime, action)
VALUES (@customer_id, @unit_id, @datetime, @action)
RETURNING *;

-- name: DeleteAccessLog :exec
DELETE FROM app.access_logs WHERE log_id = @log_id::uuid;
