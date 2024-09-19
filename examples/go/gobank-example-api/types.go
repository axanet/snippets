package main

import (
	"math/rand"
	"time"

	bcrypt "golang.org/x/crypto/bcrypt"
)

type LoginResponse struct {
	Number int64  `json:"number"`
	Token  string `json:"token"`
}

type LoginRequest struct {
	Number   int64  `json:"number"`
	Password string `json:"password"`
}

type TransferRequest struct {
	ToAccount int `json:"toAccount"`
	Amount    int `json:"amount"`
}

type CreateAccountRequest struct {
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	Password  string `json:"password"`
}

type Account struct {
	ID                int       `json:"id"`
	FirstName         string    `json:"firstName"`
	LastName          string    `json:"lastName"`
	Number            int64     `json:"number"`
	EncryptedPassword string    `json:"-"`
	Balance           int64     `json:"balance"`
	CreatedAt         time.Time `json:"createdAt"`
	UpdatedAt         time.Time `json:"updatedAt"`
}

func (a *Account) ValidPassword(password string) bool {
	if err := bcrypt.CompareHashAndPassword([]byte(a.EncryptedPassword), []byte(password)); err != nil {
		return false
	}
	return true
}

func NewAccount(firstName, lastName string, password string) (*Account, error) {
	encryptedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	return &Account{
		FirstName:         firstName,
		LastName:          lastName,
		Number:            int64(rand.Intn(100000)),
		EncryptedPassword: string(encryptedPassword),
		CreatedAt:         time.Now().UTC(),
		UpdatedAt:         time.Now().UTC(),
	}, nil
}
