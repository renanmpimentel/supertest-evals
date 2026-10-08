package payouts

import (
	"errors"
	"strings"
	"testing"
)

func TestFee(t *testing.T) {
	cases := []struct {
		name   string
		method string
		amount int64
		want   int64
	}{
		{"pix percentage", "pix", 100_000, 500},
		{"bank transfer percentage plus fixed", "bank_transfer", 100_000, 1_150},
		{"card percentage plus fixed", "card", 100_000, 2_530},
		{"rounds half up", "bank_transfer", 150, 152},
		{"rounds down below half", "bank_transfer", 149, 151},
		{"rounds half up above minimum", "pix", 10_100, 51},
		{"smallest amount", "pix", 1, 50},
		{"minimum fee", "pix", 1_000, 50},
		{"card just below minimum", "card", 760, 50},
		{"card at minimum", "card", 800, 50},
		{"card just below cap", "card", 198_760, 4_999},
		{"card highest fee below cap", "card", 198_770, 4_999},
		{"card at cap", "card", 198_800, 5_000},
		{"card just above cap", "card", 198_840, 5_000},
		{"card above cap", "card", 2_000_000, 5_000},
		{"largest amount", "pix", 1_000_000_000_000, 5_000},
	}
	for _, c := range cases {
		got, err := Fee(c.amount, c.method)
		if err != nil {
			t.Errorf("%s: Fee(%d, %q) error: %v", c.name, c.amount, c.method, err)
			continue
		}
		if got != c.want {
			t.Errorf("%s: Fee(%d, %q) = %d, want %d", c.name, c.amount, c.method, got, c.want)
		}
	}
}

func TestFeeRejectsInvalidInput(t *testing.T) {
	for _, amount := range []int64{0, -1, 1_000_000_000_001} {
		fee, err := Fee(amount, "pix")
		if !errors.Is(err, ErrInvalidAmount) {
			t.Errorf("Fee(%d, pix) error = %v, want ErrInvalidAmount", amount, err)
		}
		if fee != 0 {
			t.Errorf("Fee(%d, pix) fee = %d, want 0 with an error", amount, fee)
		}
	}
	for _, amount := range []int64{0, 1_000_000_000_001} {
		if _, err := Fee(amount, "crypto"); !errors.Is(err, ErrInvalidAmount) {
			t.Errorf("Fee(%d, crypto) error = %v, want ErrInvalidAmount", amount, err)
		}
	}
	fee, err := Fee(1_000, "crypto")
	if err == nil || !strings.Contains(err.Error(), `unknown payout method "crypto"`) {
		t.Errorf("Fee(1000, crypto) error = %v, want unknown payout method", err)
	}
	if fee != 0 {
		t.Errorf("Fee(1000, crypto) fee = %d, want 0 with an error", fee)
	}
}
