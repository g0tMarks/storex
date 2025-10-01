package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/g0tMarks/storex.git/backend/internal/db"
	_ "github.com/lib/pq"
)

func main() {
	// Pick up DATABASE_URL or fallback
	dbURI := os.Getenv("DATABASE_URL")
	if dbURI == "" {
		dbURI = "postgres://postgres:mysecretpassword@localhost:5432/test-db?sslmode=disable"
	}

	// Connect to DB
	conn, err := sql.Open("postgres", dbURI)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}
	defer conn.Close()

	if err := conn.Ping(); err != nil {
		log.Fatal("db ping failed:", err)
	}

	fmt.Println("✅ Connected to DB")

	queries := db.New(conn)
	ctx := context.Background()

	// Create a customer
	customer, err := queries.CreateCustomer(ctx, "Acme Storage Test")
	if err != nil {
		log.Fatal("failed to create customer:", err)
	}
	fmt.Printf("✅ Customer: %d %s\n", customer.CustomerID, customer.CustomerName)

	// 2️⃣ Create a facility
	facility, err := queries.CreateFacility(ctx, db.CreateFacilityParams{
		Name:    "Main Facility",
		Address: sql.NullString{String: "456 Warehouse Rd", Valid: true},
		Region:  sql.NullString{String: "VIC", Valid: true},
		Config:  []byte(`{"allow24hr": true}`), // JSONB field
	})
	if err != nil {
		log.Fatal("failed to create facility:", err)
	}
	fmt.Printf("✅ Facility: %d %s\n", facility.FacilityID, facility.Name)

	// 3️⃣ Create a unit
	unit, err := queries.CreateUnit(ctx, db.CreateUnitParams{
		FacilityID: facility.FacilityID,
		UnitType:   sql.NullString{String: "Small Locker", Valid: true},
		Size:       sql.NullString{String: "2x2", Valid: true},
		Price:      sql.NullString{String: "120.0", Valid: true},
		Column5:    db.AppUnitStatusAvailable, // enum
	})
	if err != nil {
		log.Fatal("failed to create unit:", err)
	}
	fmt.Printf("✅ Unit: %d status=%s\n", unit.UnitID, unit.Status.AppUnitStatus)

	// 4️⃣ Create an agreement
	agreement, err := queries.CreateAgreement(ctx, db.CreateAgreementParams{
		CustomerID: customer.CustomerID,
		UnitID:     unit.UnitID,
		StartDate:  time.Now(),
		EndDate:    sql.NullTime{Time: time.Now().AddDate(0, 1, 0), Valid: true},
		Column5:    db.AppAgreementStatusActive, // enum
	})
	if err != nil {
		log.Fatal("failed to create agreement:", err)
	}
	fmt.Printf("✅ Agreement: %d status=%s\n", agreement.AgreementID, agreement.Status.AppAgreementStatus)
}
