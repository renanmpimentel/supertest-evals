package payments

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strings"
	"testing"
)

func TestCreatePaymentReturnsCreated(t *testing.T) {
	db, err := OpenDB(filepath.Join(t.TempDir(), "payments.db"))
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
	if !strings.HasPrefix(body.ID, "pay_") {
		t.Errorf("id = %q, want pay_ prefix", body.ID)
	}
	if body.AmountCents != 5000 {
		t.Errorf("amount_cents = %d, want 5000", body.AmountCents)
	}
}

func TestCreatePaymentRejectsInvalidAmount(t *testing.T) {
	db, err := OpenDB(filepath.Join(t.TempDir(), "payments.db"))
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/payments", strings.NewReader(`{"amount_cents": 0}`))
	(&Handler{DB: db}).ServeHTTP(rec, req)

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusBadRequest)
	}
}
