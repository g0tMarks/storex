-- name: ListAddressesByCustomer :many
SELECT * FROM app.customer_addresses WHERE customer_id = $1 ORDER BY type;

-- name: CreateAddress :one
INSERT INTO app.customer_addresses (customer_id, type, line1, suburb, city, state, postcode, country, latitude, longitude)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
RETURNING *;

-- name: UpdateAddress :one
UPDATE app.customer_addresses
SET type = $2,
    line1 = $3,
    suburb = $4,
    city = $5,
    state = $6,
    postcode = $7,
    country = $8,
    latitude = $9,
    longitude = $10
WHERE address_id = $1
RETURNING *;

-- name: DeleteAddress :exec
DELETE FROM app.customer_addresses WHERE address_id = $1;
