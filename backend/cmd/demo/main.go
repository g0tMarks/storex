package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/g0tMarks/storex.git/backend/internal/db" // update if your module name isn’t `storex`

	_ "github.com/lib/pq"
)

func main() {
	// Use DATABASE_URL env var or fallback
	dbURI := os.Getenv("DATABASE_URL")
	if dbURI == "" {
		dbURI = "postgres://postgres:mysecretpassword@localhost:5432/postgres?sslmode=disable"
	}

	// Connect
	conn, err := sql.Open("postgres", dbURI)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}
	defer conn.Close()

	if err := conn.Ping(); err != nil {
		log.Fatal("db ping failed:", err)
	}

	queries := db.New(conn)
	ctx := context.Background()

	// Insert a new customer

	newCustomer, err := queries.CreateCustomer(ctx, db.CreateCustomerParams{
		Name: "Alice Example", // Name is NOT NULL, so string
		ContactInfo: sql.NullString{
			String: "alice@example.com",
			Valid:  true,
		},
		VerificationStatus: sql.NullString{
			String: "pending",
			Valid:  true,
		},
	})
	if err != nil {
		log.Fatal("failed to insert customer:", err)
	}

	fmt.Printf("✅ Inserted customer: ID=%d, Name=%s, Status=%s\n",
		newCustomer.CustomerID, newCustomer.Name, newCustomer.VerificationStatus)
}
