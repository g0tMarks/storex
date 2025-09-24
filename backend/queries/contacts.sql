-- name: ListContactsByCustomer :many
SELECT * FROM app.contacts WHERE customer_id = $1 ORDER BY is_primary DESC;

-- name: CreateContact :one
INSERT INTO app.contacts (customer_id, first_name, last_name, email, phone_mobile, phone_home, phone_work, role, is_primary)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING *;

-- name: UpdateContact :one
UPDATE app.contacts
SET first_name = $2,
    last_name = $3,
    email = $4,
    phone_mobile = $5,
    phone_home = $6,
    phone_work = $7,
    role = $8,
    is_primary = $9
WHERE contact_id = $1
RETURNING *;

-- name: DeleteContact :exec
DELETE FROM app.contacts WHERE contact_id = $1;
