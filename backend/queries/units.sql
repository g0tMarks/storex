-- name: ListUnits :many
SELECT * 
FROM app.units 
ORDER BY unit_id;

-- name: GetUnit :one
SELECT * 
FROM app.units 
WHERE unit_id = $1;

-- name: ListUnitsByFacility :many
SELECT * 
FROM app.units
WHERE facility_id = $1
ORDER BY unit_id;

-- name: CreateUnit :one
INSERT INTO app.units (facility_id, unit_type, size, price, status)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- name: UpdateUnit :one
UPDATE app.units
SET facility_id = $2, unit_type = $3, size = $4, price = $5, status = $6
WHERE unit_id = $1
RETURNING *;

-- name: DeleteUnit :exec
DELETE FROM app.units WHERE unit_id = $1;