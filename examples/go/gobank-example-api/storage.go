package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

type Storage interface {
	CreateAccount(*Account) error
	DeleteAccount(int) error
	UpdateAccount(*Account) error
	GetAccounts() ([]*Account, error)
	GetAccountByNumber(int64) (*Account, error)
	GetAccountByID(int) (*Account, error)
}

type PostgresStore struct {
	db *sql.DB
}

func NewPostgresStore(useDocker bool) (*PostgresStore, error) {
	connStr := "user=gobank dbname=gobank sslmode=disable password=123456"
	if useDocker {
		connStr = "user=gobank dbname=gobank sslmode=disable password=123456 host=gobank-db"
	}

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return &PostgresStore{
		db: db,
	}, nil
}

func (s *PostgresStore) Init() error {
	return s.createAccountTable()
}

func (s *PostgresStore) createAccountTable() error {
	query := `
		CREATE TABLE IF NOT EXISTS accounts (
			id SERIAL PRIMARY KEY,
			first_name varchar(255),
			last_name varchar(255),
			number serial,
			encrypted_password varchar(512),
			balance serial,
			created_at timestamp,
			updated_at timestamp
		);
	`

	_, err := s.db.Exec(query)
	return err
}

func (s *PostgresStore) CreateAccount(a *Account) error {
	query := `
		INSERT INTO accounts (first_name, last_name, number, encrypted_password, balance, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7);
	`
	_, err := s.db.Query(query, a.FirstName, a.LastName, a.Number, a.EncryptedPassword, a.Balance, a.CreatedAt, a.UpdatedAt)
	if err != nil {
		log.Panicf("Error creating account: %v", err)
		return err
	}

	return nil
}

func (s *PostgresStore) UpdateAccount(a *Account) error {
	return nil
}

func (s *PostgresStore) DeleteAccount(id int) error {
	_, err := s.db.Query("DELETE FROM accounts WHERE id = $1", id)
	if err != nil {
		return err
	}
	return nil
}

func (s *PostgresStore) GetAccounts() ([]*Account, error) {
	rows, err := s.db.Query("SELECT * FROM accounts")
	if err != nil {
		return nil, err
	}

	accounts := []*Account{}
	for rows.Next() {
		account, err := scanIntoAccount(rows)
		if err != nil {
			return nil, err
		}
		accounts = append(accounts, account)
	}

	return accounts, nil
}

func (s *PostgresStore) GetAccountByNumber(number int64) (*Account, error) {
	rows, err := s.db.Query("SELECT * FROM accounts WHERE number = $1", number)
	if err != nil {
		return nil, err
	}

	for rows.Next() {
		return scanIntoAccount(rows)
	}

	return nil, fmt.Errorf("account with number [%d] not found", number)
}

func (s *PostgresStore) GetAccountByID(id int) (*Account, error) {
	rows, err := s.db.Query("SELECT * FROM accounts WHERE id = $1", id)
	if err != nil {
		return nil, err
	}

	for rows.Next() {
		return scanIntoAccount(rows)
	}

	return nil, fmt.Errorf("account %d not found", id)
}

func scanIntoAccount(rows *sql.Rows) (*Account, error) {
	account := &Account{}
	err := rows.Scan(
		&account.ID,
		&account.FirstName,
		&account.LastName,
		&account.Number,
		&account.EncryptedPassword,
		&account.Balance,
		&account.CreatedAt,
		&account.UpdatedAt,
	)
	return account, err
}
