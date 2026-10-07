package payments

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strings"
	"testing"
)

func TestCreatePaymentIsPersisted(t *testing.T) {
	path := filepath.Join(t.TempDir(), "payments.db")
	db, err := OpenDB(path)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/payments", strings.NewReader(`{"amount_cents": 5000}`))
	(&Handler{DB: db}).ServeHTTP(rec, req)
	if rec.Code != http.StatusCreated {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusCreated)
	}
	var body createResponse
	if err := json.NewDecoder(rec.Body).Decode(&body); err != nil {
		t.Fatal(err)
	}

	reader, err := sql.Open("sqlite", path)
	if err != nil {
		t.Fatal(err)
	}
	defer reader.Close()
	var amount int64
	err = reader.QueryRow(`SELECT amount_cents FROM payments WHERE id = ?`, body.ID).Scan(&amount)
	if errors.Is(err, sql.ErrNoRows) {
		t.Fatalf("payment %s was not persisted", body.ID)
	}
	if err != nil {
		t.Fatal(err)
	}
	if amount != 5000 {
		t.Errorf("amount_cents = %d, want 5000", amount)
	}
}
