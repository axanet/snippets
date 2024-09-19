package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
	"unicode/utf8"

	jwt "github.com/golang-jwt/jwt/v4"
)

const (
	contentType     = "Content-Type"
	applicationJson = "application/json"
)

type apiFunction func(http.ResponseWriter, *http.Request) error

type ApiError struct {
	Error string `json:"error"`
}

type ApiServer struct {
	listenAddress string
	store         Storage
}

func NewApiServer(listenAddress string, store Storage) *ApiServer {
	return &ApiServer{
		listenAddress: listenAddress,
		store:         store,
	}
}

func (s *ApiServer) Run() {
	http.HandleFunc("/login", containerRequest(s.handleLogin))
	http.HandleFunc("/account", withJWTAuth(containerRequest(s.handleAccount), s.store))
	http.HandleFunc("/account/{id}", withJWTAuth(containerRequest(s.handleAccountById), s.store))
	http.HandleFunc("/transfer", containerRequest(s.handleTransfer))

	log.Printf("GoBank running on port: %s\n", s.listenAddress)

	http.ListenAndServe(s.listenAddress, nil)
}

func (s *ApiServer) handleLogin(w http.ResponseWriter, r *http.Request) error {
	if r.Method != http.MethodPost {
		methodNotAllowed(w)
	}

	var request LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		return err
	}

	account, err := s.store.GetAccountByNumber(request.Number)
	if err != nil {
		return err
	}

	if !account.ValidPassword(request.Password) {
		return fmt.Errorf("not authenticated")
	}

	token, err := createJWT(account)
	if err != nil {
		return err
	}

	return WriteJson(w, http.StatusOK, LoginResponse{Number: account.Number, Token: token})
}

func (s *ApiServer) handleAccount(w http.ResponseWriter, r *http.Request) error {
	switch r.Method {
	case "GET":
		return s.handleGetAccount(w, r)
	case "POST":
		return s.handleCreateAccount(w, r)
	case "DELETE":
		return s.handleDeleteAccount(w, r)
	default:
		methodNotAllowed(w)
		return nil
	}
}

func (s *ApiServer) handleAccountById(w http.ResponseWriter, r *http.Request) error {
	switch r.Method {
	case http.MethodGet:
		return s.handleGetAccountByID(w, r)
	case http.MethodDelete:
		return s.handleDeleteAccount(w, r)
	default:
		methodNotAllowed(w)
		return nil
	}
}

func (s *ApiServer) handleGetAccount(w http.ResponseWriter, r *http.Request) error {
	accounts, err := s.store.GetAccounts()
	if err != nil {
		return err
	}

	log.Default().Printf("Accounts: %v", accounts)
	return WriteJson(w, http.StatusOK, accounts)
}

func (s *ApiServer) handleGetAccountByID(w http.ResponseWriter, r *http.Request) error {
	id, err := getIdFromRequest(r)
	if err != nil {
		return err
	}
	account, err := s.store.GetAccountByID(id)
	if err != nil {
		return err
	}

	return WriteJson(w, http.StatusOK, account)
}

func (s *ApiServer) handleCreateAccount(w http.ResponseWriter, r *http.Request) error {
	req := &CreateAccountRequest{}
	if err := json.NewDecoder(r.Body).Decode(req); err != nil {
		return err
	}

	account, err := NewAccount(req.FirstName, req.LastName, req.Password)
	if err != nil {
		return err
	}

	if err := s.store.CreateAccount(account); err != nil {
		return err
	}

	return WriteJson(w, http.StatusCreated, account)
}

func (s *ApiServer) handleDeleteAccount(w http.ResponseWriter, r *http.Request) error {
	id, err := getIdFromRequest(r)
	if err != nil {
		return err
	}

	if err := s.store.DeleteAccount(id); err != nil {
		return err
	}
	return WriteJson(w, http.StatusNoContent, nil)
}

func (s *ApiServer) handleTransfer(w http.ResponseWriter, r *http.Request) error {
	transferRequest := &TransferRequest{}
	if err := json.NewDecoder(r.Body).Decode(transferRequest); err != nil {
		return err
	}
	defer r.Body.Close()

	return WriteJson(w, http.StatusOK, transferRequest)
}

// [ Helper Functions ]

func createJWT(account *Account) (string, error) {
	claims := &jwt.MapClaims{
		"expiresAt":     jwt.NewNumericDate(time.Unix(15000, 0)),
		"accountNumber": account.Number,
	}

	secret := os.Getenv("JWT_SECRET")
	if utf8.RuneCountInString(secret) < 1 {
		return "", fmt.Errorf("JWT_SECRET not set")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString([]byte(secret))
}

func withJWTAuth(handlerFunc http.HandlerFunc, s Storage) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// TODO: Move this logic to a lower level, as this will allow the request on every POST
		// Do not continue middleware if posting an account
		if r.Method == http.MethodPost {
			handlerFunc(w, r)
			return
		}

		log.Println("Using JWT Auth Middleware")

		tokenString := r.Header.Get("x-jwt-token")

		token, err := validateJWT(tokenString)
		if err != nil || !token.Valid {
			permissionDenied(w)
			return
		}

		claims := token.Claims.(jwt.MapClaims)

		userId, err := getIdFromRequest(r)
		if err != nil {
			permissionDenied(w)
			return
		}

		account, err := s.GetAccountByID(userId)
		if err != nil {
			permissionDenied(w)
			return
		}

		if account.Number != int64(claims["accountNumber"].(float64)) {
			permissionDenied(w)
			return
		}

		handlerFunc(w, r)
	}
}

func permissionDenied(w http.ResponseWriter) {
	WriteJson(w, http.StatusUnauthorized, ApiError{Error: "permission denied"})
}

func methodNotAllowed(w http.ResponseWriter) {
	WriteJson(w, http.StatusMethodNotAllowed, ApiError{Error: "Method not allowed"})
}

func validateJWT(tokenString string) (*jwt.Token, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return nil, fmt.Errorf("JWT_SECRET environment variable is not set")
	}

	return jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Don't forget to validate the alg is what you expect:
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}

		// hmacSampleSecret is a []byte containing your secret, e.g. []byte("my_secret_key")
		return []byte(secret), nil
	})
}

func getIdFromRequest(r *http.Request) (int, error) {
	idString := r.PathValue("id")
	id, err := strconv.Atoi(idString)
	if err != nil {
		return 0, fmt.Errorf("invalid id given %s", idString)
	}
	return id, nil
}

func WriteJson(w http.ResponseWriter, status int, v any) error {
	w.Header().Add(contentType, applicationJson)
	w.WriteHeader(status)
	return json.NewEncoder(w).Encode(v)
}

func containerRequest(f apiFunction) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := f(w, r); err != nil {
			// Handle Error
			WriteJson(w, http.StatusBadRequest, ApiError{Error: err.Error()})
		}
	}
}
