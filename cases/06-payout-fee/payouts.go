package payouts

import (
	"errors"
	"fmt"
)

// ErrInvalidAmount is returned for amounts outside (0, MaxAmountCents].
var ErrInvalidAmount = errors.New("amount must be between 1 and MaxAmountCents")

const (
	MinFeeCents    = 50
	MaxFeeCents    = 5_000
	MaxAmountCents = 1_000_000_000_000
)

type rate struct {
	basisPoints int64
	fixedCents  int64
}

var rates = map[string]rate{
	"pix":           {basisPoints: 50, fixedCents: 0},
	"bank_transfer": {basisPoints: 100, fixedCents: 150},
	"card":          {basisPoints: 250, fixedCents: 30},
}

// Fee returns the payout fee in cents: the method's percentage of the amount,
// rounded half up, plus its fixed fee, clamped to [MinFeeCents, MaxFeeCents].
func Fee(amountCents int64, method string) (int64, error) {
	if amountCents <= 0 || amountCents > MaxAmountCents {
		return 0, ErrInvalidAmount
	}
	r, ok := rates[method]
	if !ok {
		return 0, fmt.Errorf("unknown payout method %q", method)
	}
	fee := (amountCents*r.basisPoints+5_000)/10_000 + r.fixedCents
	if fee < MinFeeCents {
		return MinFeeCents, nil
	}
	if fee > MaxFeeCents {
		return MaxFeeCents, nil
	}
	return fee, nil
}
