-- name: ListCustomFieldsByCustomer :many
SELECT * FROM app.customer_custom_fields WHERE customer_id = @customer_id;

-- name: CreateCustomField :one
INSERT INTO app.customer_custom_fields (customer_id, field_name, field_value)
VALUES (@customer_id, @field_name, @field_value)
RETURNING *;

-- name: UpdateCustomField :one
UPDATE app.customer_custom_fields
SET field_name = @field_name,
    field_value = @field_value
WHERE field_id = @field_id::uuid
RETURNING *;

-- name: DeleteCustomField :exec
DELETE FROM app.customer_custom_fields WHERE field_id = @field_id::uuid;
