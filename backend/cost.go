package backend

import "fmt"

// Input is the shopkeeper's OWN credit policy applied to one customer. It is a
// transparent fairness worksheet, not a predictive risk score: every weight is
// stated by the owner and visible.
type Input struct {
	AvgMonthlyPurchase float64 `json:"avgMonthlyPurchase"`
	PctOfMonthly       float64 `json:"pctOfMonthly"`   // e.g. limit = 50% of monthly purchase
	LatePayments       int     `json:"latePayments"`   // count of recent late payments
	PenaltyPerLate     float64 `json:"penaltyPerLate"` // ₹ deducted per late payment
}

// Result is the derived, explainable credit limit.
type Result struct {
	BaseLimit        float64 `json:"baseLimit"`
	LatePenalty      float64 `json:"latePenalty"`
	RecommendedLimit float64 `json:"recommendedLimit"`
}

// Headline is the recommended limit.
func (r Result) Headline() float64 { return r.RecommendedLimit }

// Label is a coarse band for history.
func (r Result) Label() string {
	if r.RecommendedLimit <= 0 {
		return "cash-only"
	}
	return "credit-ok"
}

// Validate reports whether the Input is well formed.
func (in Input) Validate() error {
	if in.AvgMonthlyPurchase < 0 {
		return fmt.Errorf("average monthly purchase cannot be negative")
	}
	if in.PctOfMonthly < 0 || in.PctOfMonthly > 200 {
		return fmt.Errorf("percentage must be between 0 and 200")
	}
	if in.LatePayments < 0 || in.PenaltyPerLate < 0 {
		return fmt.Errorf("late count and penalty cannot be negative")
	}
	return nil
}

// Evaluate applies the owner's rule: a base limit as a percentage of monthly
// purchase, less a flat penalty per recent late payment, floored at zero.
func Evaluate(in Input) Result {
	base := in.AvgMonthlyPurchase * in.PctOfMonthly / 100
	penalty := float64(in.LatePayments) * in.PenaltyPerLate
	limit := base - penalty
	if limit < 0 {
		limit = 0
	}
	return Result{BaseLimit: base, LatePenalty: penalty, RecommendedLimit: limit}
}
