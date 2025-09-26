-- name: ListCustomFieldsByCustomer :many
SELECT * FROM app.customer_custom_fields WHERE customer_id = $1;

-- name: CreateCustomField :one
INSERT INTO app.customer_custom_fields (customer_id, field_name, field_value)
VALUES ($1, $2, $3)
RETURNING *;

-- name: UpdateCustomField :one
UPDATE app.customer_custom_fields
SET field_name = $2,
    field_value = $3
WHERE field_id = $1
RETURNING *;

-- name: DeleteCustomField :exec
DELETE FROM app.customer_custom_fields WHERE field_id = $1;
