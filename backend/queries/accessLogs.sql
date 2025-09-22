-- name: ListAccessLogs :many
SELECT * FROM app.access_logs ORDER BY datetime DESC;

-- name: GetAccessLogsByCustomer :many
SELECT * FROM app.access_logs WHERE customer_id = $1 ORDER BY datetime DESC;

-- name: GetAccessLogsByUnit :many
SELECT * FROM app.access_logs WHERE unit_id = $1 ORDER BY datetime DESC;

-- name: CreateAccessLog :one
INSERT INTO app.access_logs (customer_id, unit_id, datetime, action)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: DeleteAccessLog :exec
DELETE FROM app.access_logs WHERE log_id = $1;
