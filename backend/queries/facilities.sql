-- name: ListFacilities :many
SELECT * 
FROM app.facilities 
ORDER BY name;

-- name: GetFacility :one
SELECT * 
FROM app.facilities 
WHERE facility_id = $1;

-- name: CreateFacility :one
INSERT INTO app.facilities (
    name,
    address,
    region,
    config
) VALUES (
    $1, $2, $3, $4
)
RETURNING *;