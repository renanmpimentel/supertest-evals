package routing

import (
	"errors"
	"testing"
)

// Cards that pass the Luhn check, by scheme and leading digits.
const (
	visaPlain      = "4012888800000008" // no table entry
	visaBin6       = "4111110000000005" // 411111
	visaBin6Other  = "4111111100000002" // 411111, not in bin8
	visaBin8       = "4111119000000006" // 41111190
	visa12         = "400000000002"
	visa13         = "4000000000006"
	visa19         = "4000000000000000006"
	visa11         = "40000000006"
	visa20         = "40000000000000000002"
	mastercard51   = "5100000000000008"
	mastercardBin6 = "5555550000000002" // 555555
	mastercardBin8 = "5555550000000002"
	mastercard52   = "5200000000000007"
	mastercard54   = "5400000000000005"
	mastercard50   = "5000000000000009"
	mastercard56   = "5600000000000003"
	mastercard15   = "510000000000003"
	mastercard17   = "51000000000000003"
	amex34         = "340000000000009"
	amex37         = "370000000000002"
	amexBin6       = "378282000000008" // 378282
	amex14         = "34000000000000"
	amex16         = "3400000000000000"
	amex33         = "330000000000001"
	amex35         = "350000000000006"
	amex36         = "360000000000004"
	amex38         = "380000000000000"
	unknownScheme  = "6011000000000004"
)

func newTestRouter() *Router {
	return NewRouter(
		map[string]string{"41111190": "delta", "55555500": "echo"},
		map[string]string{"411111": "delta", "555555": "echo", "378282": "foxtrot"},
	)
}

func route(t *testing.T, card, currency string, amount int64) Result {
	t.Helper()
	res, err := newTestRouter().Route(card, currency, amount)
	if err != nil {
		t.Fatalf("Route(%q, %q, %d) returned error: %v", card, currency, amount, err)
	}
	return res
}

func routeErr(card, currency string, amount int64) error {
	_, err := newTestRouter().Route(card, currency, amount)
	return err
}

func TestSchemeDefaultAcquirer(t *testing.T) {
	cases := []struct {
		card, scheme, acquirer string
	}{
		{visaPlain, "visa", "alpha"},
		{mastercard51, "mastercard", "bravo"},
		{amex34, "amex", "charlie"},
		{amex37, "amex", "charlie"},
	}
	for _, c := range cases {
		got := route(t, c.card, "BRL", 1000)
		if got.Scheme != c.scheme || got.Acquirer != c.acquirer {
			t.Errorf("card %s = %+v, want scheme %s acquirer %s", c.card, got, c.scheme, c.acquirer)
		}
	}
}

func TestSixDigitEntryOverridesSchemeDefault(t *testing.T) {
	cases := []struct {
		card, scheme, acquirer string
	}{
		{visaBin6, "visa", "delta"},
		{visaBin6Other, "visa", "delta"},
		{mastercardBin6, "mastercard", "echo"},
		{amexBin6, "amex", "foxtrot"},
	}
	for _, c := range cases {
		got := route(t, c.card, "USD", 1000)
		if got.Scheme != c.scheme || got.Acquirer != c.acquirer {
			t.Errorf("card %s = %+v, want scheme %s acquirer %s", c.card, got, c.scheme, c.acquirer)
		}
	}
}

func TestEightDigitEntryIsUsed(t *testing.T) {
	if got := route(t, visaBin8, "BRL", 1000); got.Acquirer != "delta" {
		t.Errorf("acquirer = %s, want delta", got.Acquirer)
	}
	if got := route(t, mastercardBin8, "BRL", 1000); got.Acquirer != "echo" {
		t.Errorf("acquirer = %s, want echo", got.Acquirer)
	}
}

func TestRouteWithoutTables(t *testing.T) {
	r := NewRouter(nil, nil)
	got, err := r.Route(visaBin6, "BRL", 1000)
	if err != nil || got.Acquirer != "alpha" {
		t.Errorf("got %+v, %v; want acquirer alpha", got, err)
	}
}

func TestCardNumberIsNormalized(t *testing.T) {
	for _, card := range []string{"4111 1100 0000 0005", "4111-1100-0000-0005", " 4111 - 1100 0000 0005 "} {
		got := route(t, card, "BRL", 1000)
		if got.Acquirer != "delta" {
			t.Errorf("card %q acquirer = %s, want delta", card, got.Acquirer)
		}
	}
}

func TestInvalidCardNumbers(t *testing.T) {
	cases := map[string]string{
		"empty":                            "",
		"letters":                          "4111x1100000005",
		"symbol with a luhn-neutral value": "411111000000000?",
		"failed luhn":                      "4012888800000009",
		"11 digits":                        visa11,
		"20 digits":                        visa20,
		"mastercard 15":                    mastercard15,
		"mastercard 17":                    mastercard17,
		"amex 14":                          amex14,
		"amex 16":                          amex16,
		"only separators":                  " - - ",
		"separators and text":              "4111 1100 0000 000a",
	}
	for name, card := range cases {
		if err := routeErr(card, "BRL", 1000); !errors.Is(err, ErrInvalidCard) {
			t.Errorf("%s: err = %v, want ErrInvalidCard", name, err)
		}
	}
}

func TestCardLengthLimits(t *testing.T) {
	for _, card := range []string{visa12, visa13, visa19} {
		if err := routeErr(card, "BRL", 1000); err != nil {
			t.Errorf("card %s: unexpected error %v", card, err)
		}
	}
}

func TestSchemeLeadingDigits(t *testing.T) {
	accepted := map[string]string{
		visaPlain:      "visa",
		mastercard51:   "mastercard",
		mastercard52:   "mastercard",
		mastercard54:   "mastercard",
		mastercardBin6: "mastercard",
		amex34:         "amex",
		amex37:         "amex",
	}
	for card, scheme := range accepted {
		if got := route(t, card, "EUR", 1000); got.Scheme != scheme {
			t.Errorf("card %s scheme = %s, want %s", card, got.Scheme, scheme)
		}
	}
	for _, card := range []string{mastercard50, mastercard56, amex33, amex35, amex36, amex38, unknownScheme} {
		if err := routeErr(card, "EUR", 1000); !errors.Is(err, ErrUnsupportedScheme) {
			t.Errorf("card %s: err = %v, want ErrUnsupportedScheme", card, err)
		}
	}
}

func TestSupportedCurrencies(t *testing.T) {
	for _, currency := range []string{"BRL", "USD", "EUR"} {
		if err := routeErr(visaPlain, currency, 1000); err != nil {
			t.Errorf("currency %s: unexpected error %v", currency, err)
		}
	}
	for _, currency := range []string{"", "brl", "GBP", "BR", "BRLL"} {
		if err := routeErr(visaPlain, currency, 1000); !errors.Is(err, ErrUnsupportedCurrency) {
			t.Errorf("currency %q: err = %v, want ErrUnsupportedCurrency", currency, err)
		}
	}
}

func TestAmountMustBePositive(t *testing.T) {
	for _, amount := range []int64{0, -1, -1000} {
		if err := routeErr(visaPlain, "BRL", amount); !errors.Is(err, ErrInvalidAmount) {
			t.Errorf("amount %d: err = %v, want ErrInvalidAmount", amount, err)
		}
	}
	if err := routeErr(visaPlain, "BRL", 1); err != nil {
		t.Errorf("amount 1: unexpected error %v", err)
	}
}

func TestAmountLimitPerScheme(t *testing.T) {
	cases := []struct {
		card  string
		limit int64
	}{
		{visaPlain, 10_000_000},
		{mastercard51, 10_000_000},
		{amex34, 5_000_000},
	}
	for _, c := range cases {
		if err := routeErr(c.card, "BRL", c.limit); err != nil {
			t.Errorf("card %s at the limit: unexpected error %v", c.card, err)
		}
		if err := routeErr(c.card, "BRL", c.limit+1); !errors.Is(err, ErrAmountTooHigh) {
			t.Errorf("card %s above the limit: err = %v, want ErrAmountTooHigh", c.card, err)
		}
	}
}
