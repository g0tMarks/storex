-- name: ListAddressesByCustomer :many
SELECT * FROM app.customer_addresses WHERE customer_id = @customer_id ORDER BY type;

-- name: CreateAddress :one
INSERT INTO app.customer_addresses (customer_id, type, line1, suburb, city, state, postcode, country, latitude, longitude)
VALUES (@customer_id, @type, @line1, @suburb, @city, @state, @postcode, @country, @latitude, @longitude)
RETURNING *;

-- name: UpdateAddress :one
UPDATE app.customer_addresses
SET type = @type,
    line1 = @line1,
    suburb = @suburb,
    city = @city,
    state = @state,
    postcode = @postcode,
    country = @country,
    latitude = @latitude,
    longitude = @longitude
WHERE address_id = @address_id::uuid
RETURNING *;

-- name: DeleteAddress :exec
DELETE FROM app.customer_addresses WHERE address_id = @address_id::uuid;
