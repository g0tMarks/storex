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
VALUES (@facility_id, @unit_type, @size, @price, @status::app.unit_status)
RETURNING *;

-- name: UpdateUnit :one
UPDATE app.units
SET facility_id = @facility_id, unit_type = @unit_type, size = @size, price = @price, status = @status::app.unit_status
WHERE unit_id = @unit_id
RETURNING *;

-- name: DeleteUnit :exec
DELETE FROM app.units WHERE unit_id = $1;