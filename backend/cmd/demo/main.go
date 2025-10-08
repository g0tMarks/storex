package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	// Requires a fully qualified module path
	"github.com/g0tMarks/storex.git/backend/internal/db"
	"github.com/joho/godotenv"

	//The underscore imports the package as well as runs its init() function
	_ "github.com/lib/pq"
)

func main() {
	// Load .env file manually
	// Adjust path as needed because by default it looks in the current working directory for .env
	err := godotenv.Load("../../../.env")
	if err != nil {
		fmt.Println("No .env file found, using environment variables")
		fmt.Printf("%s\n", err)
	}

	dbURI := os.Getenv("DATABASE_URL")
	if dbURI == "" {
		dbURI = "postgres://postgres:mysecretpassword@localhost:5432/test-db?sslmode=disable"
	}

	fmt.Println("DB URI:", dbURI)

	// Connect to DB
	// sql.Open() is from lib/pq and requires a driver name "postgres" as the first argument and the URL as the second argument
	if err != nil {
		conn, err := sql.Open("postgres", dbURI)
		log.Fatal("cannot connect to db:", err)
	}

	//defer the close to the end of main()
	defer conn.Close()

	// Ping to verify connection
	if err := conn.Ping(); err != nil {
		log.Fatal("db ping failed:", err)
	}

	fmt.Println("Connected to DB")

	//db.New() is from sqlc generated code in internal/db/db.go
	queries := db.New(conn)
	// Context for DB operations
	ctx := context.Background()

	// 1 Create a customer
	customer, err := queries.CreateCustomer(ctx, "Acme Storage Test")
	if err != nil {
		log.Fatal("failed to create customer:", err)
	}
	fmt.Printf("1. DONE! Created Customer: %d %s\n", customer.CustomerID, customer.CustomerName)

	// 2 Create a facility
	facility, err := queries.CreateFacility(ctx, db.CreateFacilityParams{
		Name:    "Main Facility",
		Address: sql.NullString{String: "456 Warehouse Rd", Valid: true},
		Region:  sql.NullString{String: "VIC", Valid: true},
		Config:  []byte(`{"allow24hr": true}`), // JSONB field
	})
	if err != nil {
		log.Fatal("failed to create facility:", err)
	}
	fmt.Printf("2. DONE! Created Facility: %d %s\n", facility.FacilityID, facility.Name)

	// 3 Create a unit
	unit, err := queries.CreateUnit(ctx, db.CreateUnitParams{
		FacilityID: facility.FacilityID,
		UnitType:   sql.NullString{String: "Small Locker", Valid: true},
		Size:       sql.NullString{String: "2x2", Valid: true},
		Price:      sql.NullString{String: "120.0", Valid: true},
		//Status:     db.AppUnitStatusAvailable, // enum
	})
	if err != nil {
		log.Fatal("failed to create unit:", err)
	}
	fmt.Printf("Unit: %d status=%s\n", unit.UnitID, unit.Status)
	/*
	   // 4 Create an agreement

	   	agreement, err := queries.CreateAgreement(ctx, db.CreateAgreementParams{
	   		CustomerID: customer.CustomerID,
	   		UnitID:     unit.UnitID,
	   		StartDate:  time.Now(),
	   		EndDate:    sql.NullTime{Time: time.Now().AddDate(0, 1, 0), Valid: true},
	   			Status:     db.AgreementStatusActive, // enum
	   		})
	   		if err != nil {
	   			log.Fatal("failed to create agreement:", err)
	   		}
	   		fmt.Printf("Agreement: %d status=%s\n", agreement.AgreementID, agreement.Status)

	   // 6 Record a payment

	   	payment, err := queries.CreatePayment(ctx, db.CreatePaymentParams{
	   		Method:     sql.NullString{String: "credit_card", Valid: true},
	   		GatewayRef: sql.NullString{String: "TXN-12345", Valid: true},
	   		Status:     db.PaymentStatusCompleted, // enum
	   	})
	   	if err != nil {
	   		log.Fatal("failed to create payment:", err)
	   	}
	   	fmt.Printf("Payment: %d status=%s\n", payment.PaymentID, payment.Status)

	   // 7 Log a message

	   	message, err := queries.CreateMessage(ctx, db.CreateMessageParams{
	   		CustomerID: customer.CustomerID,
	   		Type:       db.MessageTypeEmail,         // enum
	   		Direction:  db.MessageDirectionOutbound, // enum
	   		Status:     db.MessageStatusSent,        // enum
	   	})
	   	if err != nil {
	   		log.Fatal("failed to create message:", err)
	   	}
	   	fmt.Printf("Message: %d type=%s status=%s\n", message.MessageID, message.Type, message.Status)

	   	// Done
	   	fmt.Println("Full demo flow completed successfully.")
	*/
}
