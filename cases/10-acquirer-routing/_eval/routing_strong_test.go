package routing

import "testing"

func TestEightDigitEntryOverridesSixDigitEntry(t *testing.T) {
	r := NewRouter(
		map[string]string{"41111190": "golf"},
		map[string]string{"411111": "delta"},
	)
	got, err := r.Route("4111119000000006", "BRL", 1000)
	if err != nil {
		t.Fatal(err)
	}
	if got.Acquirer != "golf" {
		t.Errorf("8-digit entry ignored: acquirer = %s, want golf", got.Acquirer)
	}
	got, err = r.Route("4111110000000005", "BRL", 1000)
	if err != nil {
		t.Fatal(err)
	}
	if got.Acquirer != "delta" {
		t.Errorf("6-digit entry: acquirer = %s, want delta", got.Acquirer)
	}
}
