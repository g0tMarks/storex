-- name: ListMessages :many
SELECT * FROM app.messages ORDER BY message_id DESC;

-- name: GetMessagesByCustomer :many
SELECT * FROM app.messages WHERE customer_id = @customer_id ORDER BY message_id DESC;

-- name: CreateMessage :one
INSERT INTO app.messages (customer_id, type, direction, status)
VALUES (@customer_id, @type::app.message_type, @direction::app.message_direction, @status::app.message_status)
RETURNING *;

-- name: UpdateMessage :one
UPDATE app.messages
SET type = @type::app.message_type, direction = @direction::app.message_direction, status = @status::app.message_status
WHERE message_id = @message_id::uuid
RETURNING *;

-- name: DeleteMessage :exec
DELETE FROM app.messages WHERE message_id = @message_id::uuid;
