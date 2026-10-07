package payments

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"net/http"

	_ "modernc.org/sqlite"
)

type Handler struct {
	DB *sql.DB
}

type createRequest struct {
	AmountCents int64 `json:"amount_cents"`
}

type createResponse struct {
	ID          string `json:"id"`
	AmountCents int64  `json:"amount_cents"`
}

func OpenDB(path string) (*sql.DB, error) {
	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, err
	}
	if _, err := db.Exec(`CREATE TABLE IF NOT EXISTS payments (
		id TEXT PRIMARY KEY,
		amount_cents INTEGER NOT NULL
	)`); err != nil {
		db.Close()
		return nil, err
	}
	return db, nil
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var req createRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.AmountCents <= 0 {
		http.Error(w, "invalid payment", http.StatusBadRequest)
		return
	}
	id, err := newID()
	if err != nil {
		http.Error(w, "could not create payment id", http.StatusInternalServerError)
		return
	}

	tx, err := h.DB.BeginTx(r.Context(), nil)
	if err != nil {
		http.Error(w, "could not save payment", http.StatusInternalServerError)
		return
	}
	defer tx.Rollback()
	if _, err := tx.Exec(`INSERT INTO payments (id, amount_cents) VALUES (?, ?)`, id, req.AmountCents); err != nil {
		http.Error(w, "could not save payment", http.StatusInternalServerError)
		return
	}
	if err := tx.Commit(); err != nil {
		http.Error(w, "could not save payment", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(createResponse{ID: id, AmountCents: req.AmountCents})
}

func newID() (string, error) {
	b := make([]byte, 8)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return "pay_" + hex.EncodeToString(b), nil
}
