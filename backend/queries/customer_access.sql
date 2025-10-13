-- name: GetAccessByCustomer :one
SELECT * FROM app.customer_access WHERE customer_id = @customer_id;

-- name: CreateAccess :one
INSERT INTO app.customer_access (customer_id, pin, always_allowed, time_zone)
VALUES (@customer_id, @pin, @always_allowed, @time_zone)
RETURNING *;

-- name: UpdateAccess :one
UPDATE app.customer_access
SET pin = @pin,
    always_allowed = @always_allowed,
    time_zone = @time_zone
WHERE access_id = @access_id::uuid
RETURNING *;

-- name: DeleteAccess :exec
DELETE FROM app.customer_access WHERE access_id = @access_id::uuid;
