-- name: ListMessages :many
SELECT * FROM app.messages ORDER BY message_id DESC;

-- name: GetMessagesByCustomer :many
SELECT * FROM app.messages WHERE customer_id = $1 ORDER BY message_id DESC;

-- name: CreateMessage :one
INSERT INTO app.messages (customer_id, type, direction, status)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: UpdateMessage :one
UPDATE app.messages
SET type = $2, direction = $3, status = $4
WHERE message_id = $1
RETURNING *;

-- name: DeleteMessage :exec
DELETE FROM app.messages WHERE message_id = $1;
