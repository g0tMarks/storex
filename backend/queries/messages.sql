-- name: ListMessages :many
SELECT * FROM app.messages ORDER BY message_id DESC;

-- name: GetMessagesByCustomer :many
SELECT * FROM app.messages WHERE customer_id = $1 ORDER BY message_id DESC;

-- name: CreateMessage :one
INSERT INTO app.messages (customer_id, type, direction, status)
VALUES ($1, $2::app.message_type, $3::app.message_direction, $4::app.message_status)
RETURNING *;

-- name: UpdateMessage :one
UPDATE app.messages
SET type = $2::app.message_type, direction = $3::app.message_direction, status = $4::app.message_status
WHERE message_id = $1
RETURNING *;

-- name: DeleteMessage :exec
DELETE FROM app.messages WHERE message_id = $1;
