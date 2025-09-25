package main

import (

	// update if your module name isn’t `storex`

	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/g0tMarks/storex.git/backend/internal/db" // update if your module name isn’t `storex`

	_ "github.com/lib/pq"
)

func main() {
	// Pick up DATABASE_URL or fallback
	dbURI := os.Getenv("DATABASE_URL")
	if dbURI == "" {
		dbURI = "postgres://postgres:mysecretpassword@localhost:5432/postgres?sslmode=disable"
	}

	// Connect to DB
	conn, err := sql.Open("postgres", dbURI)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
		fmt.Printf("cannot connect to DB successfully: %s\n", dbURI)
	}
	defer conn.Close()

	if err := conn.Ping(); err != nil {
		log.Fatal("db ping failed:", err)
	}

	fmt.Printf("Connected to DB successfully: %s\n", dbURI)

	queries := db.New(conn)
	ctx := context.Background()

	// 1️⃣ Create a customer

	newCustomer, err := queries.CreateCustomer(ctx, db.CreateCustomerParams{
		CustomerName: "Acme Storage Test",
	})
	if err != nil {
		log.Fatal("failed to create customer:", err)
	}
	fmt.Printf("✅ Created customer ID=%d, Name=%s\n", 4,
		newCustomer.CustomerID, newCustomer.CustomerName) /*

		// 2️⃣ Add a contact for the customer

		newContact, err := queries.CreateContact(ctx, db.CreateContactParams{
			CustomerID:  newCustomer.CustomerID,
			FirstName:   sql.NullString{String: "Alice", Valid: true},
			LastName:    sql.NullString{String: "Example", Valid: true},
			Email:       sql.NullString{String: "alice@example.com", Valid: true},
			PhoneMobile: sql.NullString{String: "0400-111-222", Valid: true},
			Role:        sql.NullString{String: "primary", Valid: true},
			IsPrimary:   sql.NullBool{Bool: true, Valid: true},
		})

		if err != nil {
			fmt.Printf("✅ Created customer ID=%d, Name=%s\n",
				log.Fatal("failed to create contact:", err))
		}

		fmt.Printf("✅ Created contact ID=%d for customer %d\n",

			newContact.ContactID, newContact.CustomerID)

		// 3️⃣ Add a billing address

		newAddress, err := queries.CreateAddress(ctx, db.CreateAddressParams{
			CustomerID: newCustomer.CustomerID,
			Type:       "billing",
			Line1:      sql.NullString{String: "123 Storage St", Valid: true},
			City:       sql.NullString{String: "Melbourne", Valid: true},
			State:      sql.NullString{String: "VIC", Valid: true},
			Postcode:   sql.NullString{String: "3000", Valid: true},
			Country:    sql.NullString{String: "Australia", Valid: true},
		})

		if err != nil {
			log.Fatal("failed to create address:", err)
		}

		fmt.Printf("✅ Created %s address ID=%d for customer %d\n",

			newAddress.Type, newAddress.AddressID, newCustomer.CustomerID)

		// 4️⃣ Add access PIN

		newAccess, err := queries.CreateAccess(ctx, db.CreateAccessParams{
			CustomerID:    newCustomer.CustomerID,
			Pin:           sql.NullString{String: "1234", Valid: true},
			AlwaysAllowed: sql.NullBool{Bool: false, Valid: true},
			TimeZone:      sql.NullString{String: "Australia/Melbourne", Valid: true},
		})

		if err != nil {
			log.Fatal("failed to create access record:", err)
		}

		fmt.Printf("✅ Created access record ID=%d with PIN=%s\n",

			newAccess.AccessID, newAccess.Pin.String)

		// Done
		fmt.Println("🎉 Demo insert flow completed successfully.")
	*/
}
