package policy

import (
	"os"

	"github.com/dasmlab/orca-runner/pkg/report"
	"gopkg.in/yaml.v3"
)

type Document struct {
	Name        string `yaml:"name"`
	Description string `yaml:"description"`
	Rules       []Rule `yaml:"rules"`
}

type Rule struct {
	ID          string `yaml:"id"`
	ThreatClass string `yaml:"threat_class"`
	Severity    string `yaml:"severity"`
	Action      string `yaml:"action"` // fail | warn
	Match       string `yaml:"match"`  // finding id
}

type Decision struct {
	Label    string
	Summary  string
	ExitCode int
}

func Load(path string) (*Document, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var doc Document
	if err := yaml.Unmarshal(data, &doc); err != nil {
		return nil, err
	}
	return &doc, nil
}

func (d *Document) ActionForFinding(findingID string) string {
	best := "pass"
	rank := map[string]int{"pass": 0, "warn": 1, "fail": 2}
	current := 0
	for _, rule := range d.Rules {
		if rule.Match != findingID {
			continue
		}
		action := rule.Action
		if action == "" {
			action = "warn"
		}
		if rank[action] > current {
			current = rank[action]
			best = action
		}
	}
	return best
}

func (d *Document) Evaluate(findings []report.Finding) Decision {
	actionRank := map[string]int{"pass": 0, "warn": 1, "fail": 2}
	best := Decision{Label: "pass", Summary: "No policy violations", ExitCode: 0}
	currentRank := 0

	for _, f := range findings {
		action := d.ActionForFinding(f.ID)
		if action == "pass" {
			continue
		}
		rank := actionRank[action]
		if rank > currentRank {
			currentRank = rank
			switch action {
			case "fail":
				best = Decision{Label: "fail", Summary: f.Title, ExitCode: 2}
			case "warn":
				best = Decision{Label: "warn", Summary: f.Title, ExitCode: 1}
			}
		}
	}

	if best.Label == "pass" && len(findings) > 0 {
		best = Decision{Label: "warn", Summary: "Findings present without matching fail rules", ExitCode: 1}
	}
	return best
}
