package main

import (
	"flag"
	"log"
)

func main() {
	seed := flag.Bool("seed", false, "Set this flag to true to seed the database during startup")
	docker := flag.Bool("docker", false, "Set this flag to set the database host to 'gobank-db' instead of localhost")
	flag.Parse()

	if err := LoadEnv("./.env"); err != nil {
		log.Fatalf("Error loading environment: %v", err)
	} else {
		log.Println("Environment initialized")
	}

	store, err := NewPostgresStore(*docker)
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	} else {
		log.Println("Connected to database")
	}

	if err := store.Init(); err != nil {
		log.Fatalf("Error initializing database: %v", err)
	} else {
		log.Println("Database initialized")
	}

	// Seed Database
	if *seed {
		log.Println("seeding the database")
		seedAccounts(store)
		log.Println("seeding completed")
	}

	server := NewApiServer(":9090", store)
	server.Run()
}

func seedAccounts(s Storage) {
	seedAccount(s, "Ruli", "brate", "skibidiToilet69")
}

func seedAccount(store Storage, firstName, lastName, password string) *Account {
	account, err := NewAccount(firstName, lastName, password)
	if err != nil {
		log.Fatal(err)
	}

	if err := store.CreateAccount(account); err != nil {
		log.Fatal(err)
	}

	log.Println("New Account => ", account.Number)

	return account
}
