-- name: ListContactsByCustomer :many
SELECT * FROM app.contacts WHERE customer_id = @customer_id ORDER BY is_primary DESC;

-- name: CreateContact :one
INSERT INTO app.contacts (customer_id, first_name, last_name, email, phone_mobile, phone_home, phone_work, role, is_primary)
VALUES (@customer_id, @first_name, @last_name, @email, @phone_mobile, @phone_home, @phone_work, @role, @is_primary)
RETURNING *;

-- name: UpdateContact :one
UPDATE app.contacts
SET first_name = @first_name,
    last_name = @last_name,
    email = @email,
    phone_mobile = @phone_mobile,
    phone_home = @phone_home,
    phone_work = @phone_work,
    role = @role,
    is_primary = @is_primary
WHERE contact_id = @contact_id
RETURNING *;

-- name: DeleteContact :exec
DELETE FROM app.contacts WHERE contact_id = @contact_id;
