-- name: ListFacilities :many
SELECT * 
FROM app.facilities 
ORDER BY name;

-- name: GetFacility :one
SELECT * 
FROM app.facilities 
WHERE facility_id = @facility_id::uuid;

-- name: CreateFacility :one
INSERT INTO app.facilities (
    name,
    address,
    region,
    config
) VALUES (
    @name, @address, @region, @config
)
RETURNING *;