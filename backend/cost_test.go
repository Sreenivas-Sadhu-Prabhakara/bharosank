package backend

import (
	"encoding/json"
	"math"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestEvaluate_LimitFromRule(t *testing.T) {
	// 50% of ₹8000 = 4000 base, less 2 late × ₹500 = 1000 → ₹3000.
	r := Evaluate(Input{AvgMonthlyPurchase: 8000, PctOfMonthly: 50, LatePayments: 2, PenaltyPerLate: 500})
	if math.Abs(r.BaseLimit-4000) > 1e-9 || math.Abs(r.RecommendedLimit-3000) > 1e-9 {
		t.Fatalf("result wrong: %+v", r)
	}
}

func TestEvaluate_FlooredAtZero(t *testing.T) {
	r := Evaluate(Input{AvgMonthlyPurchase: 1000, PctOfMonthly: 50, LatePayments: 5, PenaltyPerLate: 500})
	if r.RecommendedLimit != 0 || r.Label() != "cash-only" {
		t.Fatalf("expected floored cash-only, got %+v", r)
	}
}

func TestValidate(t *testing.T) {
	if err := (Input{AvgMonthlyPurchase: 8000, PctOfMonthly: 50}).Validate(); err != nil {
		t.Fatalf("valid rejected: %v", err)
	}
	for i, bad := range []Input{{PctOfMonthly: 300}, {AvgMonthlyPurchase: -1}, {LatePayments: -1}} {
		if err := bad.Validate(); err == nil {
			t.Fatalf("bad %d accepted", i)
		}
	}
}

func TestEvaluateEndpoint(t *testing.T) {
	srv := NewServer(nil)
	rec := httptest.NewRecorder()
	srv.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/evaluate",
		strings.NewReader(`{"avgMonthlyPurchase":8000,"pctOfMonthly":50,"latePayments":2,"penaltyPerLate":500}`)))
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d", rec.Code)
	}
	var r Result
	json.Unmarshal(rec.Body.Bytes(), &r)
	if math.Abs(r.RecommendedLimit-3000) > 1e-9 {
		t.Fatalf("limit=%v want 3000", r.RecommendedLimit)
	}
}
