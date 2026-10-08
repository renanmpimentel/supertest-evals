package routing

import (
	"errors"
	"strings"
)

var (
	ErrInvalidCard         = errors.New("invalid card number")
	ErrUnsupportedScheme   = errors.New("unsupported card scheme")
	ErrUnsupportedCurrency = errors.New("unsupported currency")
	ErrInvalidAmount       = errors.New("amount must be positive")
	ErrAmountTooHigh       = errors.New("amount above the scheme limit")
)

const (
	binLong          = 8
	binShort         = 6
	minLength        = 12
	maxLength        = 19
	amexLength       = 15
	mastercardLength = 16
)

type scheme struct {
	name     string
	acquirer string
	limit    int64
}

var (
	visa       = scheme{"visa", "alpha", 10_000_000}
	mastercard = scheme{"mastercard", "bravo", 10_000_000}
	amex       = scheme{"amex", "charlie", 5_000_000}
)

type Result struct {
	Scheme   string
	Acquirer string
}

type Router struct {
	bin8 map[string]string
	bin6 map[string]string
}

func NewRouter(bin8, bin6 map[string]string) *Router {
	return &Router{bin8: bin8, bin6: bin6}
}

func (r *Router) Route(card, currency string, amountMinor int64) (Result, error) {
	digits, err := normalize(card)
	if err != nil {
		return Result{}, err
	}
	sch, err := schemeOf(digits)
	if err != nil {
		return Result{}, err
	}
	if currency != "BRL" && currency != "USD" && currency != "EUR" {
		return Result{}, ErrUnsupportedCurrency
	}
	if amountMinor <= 0 {
		return Result{}, ErrInvalidAmount
	}
	if amountMinor > sch.limit {
		return Result{}, ErrAmountTooHigh
	}
	return Result{Scheme: sch.name, Acquirer: r.acquirer(digits, sch)}, nil
}

func (r *Router) acquirer(digits string, sch scheme) string {
	if a, ok := r.bin8[digits[:binLong]]; ok {
		return a
	}
	if a, ok := r.bin6[digits[:binShort]]; ok {
		return a
	}
	return sch.acquirer
}

func normalize(card string) (string, error) {
	digits := strings.NewReplacer(" ", "", "-", "").Replace(card)
	if len(digits) < minLength || len(digits) > maxLength {
		return "", ErrInvalidCard
	}
	for _, c := range digits {
		if c < '0' || c > '9' {
			return "", ErrInvalidCard
		}
	}
	if !luhn(digits) {
		return "", ErrInvalidCard
	}
	return digits, nil
}

func luhn(digits string) bool {
	sum := 0
	double := false
	for i := len(digits) - 1; i >= 0; i-- {
		n := int(digits[i] - '0')
		if double {
			n *= 2
			if n > 9 {
				n -= 9
			}
		}
		sum += n
		double = !double
	}
	return sum%10 == 0
}

func schemeOf(digits string) (scheme, error) {
	prefix := int(digits[0]-'0')*10 + int(digits[1]-'0')
	switch {
	case digits[0] == '4':
		return visa, nil
	case prefix >= 51 && prefix <= 55:
		if len(digits) != mastercardLength {
			return scheme{}, ErrInvalidCard
		}
		return mastercard, nil
	case prefix == 34 || prefix == 37:
		if len(digits) != amexLength {
			return scheme{}, ErrInvalidCard
		}
		return amex, nil
	}
	return scheme{}, ErrUnsupportedScheme
}
