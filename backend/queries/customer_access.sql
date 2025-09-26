-- name: GetAccessByCustomer :one
SELECT * FROM app.customer_access WHERE customer_id = $1;

-- name: CreateAccess :one
INSERT INTO app.customer_access (customer_id, pin, always_allowed, time_zone)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: UpdateAccess :one
UPDATE app.customer_access
SET pin = $2,
    always_allowed = $3,
    time_zone = $4
WHERE access_id = $1
RETURNING *;

-- name: DeleteAccess :exec
DELETE FROM app.customer_access WHERE access_id = $1;
