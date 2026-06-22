package report

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
	"time"
)

type Finding struct {
	ID          string `json:"id"`
	ThreatClass string `json:"threat_class"`
	Severity    string `json:"severity"`
	Title       string `json:"title"`
	Detail      string `json:"detail"`
	Source      string `json:"source"`
}

type ThreatClassSummary struct {
	ThreatClass     string `json:"threat_class"`
	FindingCount    int    `json:"finding_count"`
	HighestSeverity string `json:"highest_severity"`
	PolicyAction    string `json:"policy_action"`
}

type Evaluation struct {
	ByThreatClass []ThreatClassSummary `json:"by_threat_class"`
	TotalFindings int                  `json:"total_findings"`
}

type Document struct {
	Schema      string     `json:"schema"`
	Tool        string     `json:"tool"`
	ToolVersion string     `json:"tool_version"`
	GeneratedAt time.Time  `json:"generated_at"`
	Target      string     `json:"target"`
	Policy      string     `json:"policy"`
	Decision    string     `json:"decision"`
	Summary     string     `json:"summary"`
	Evaluation  Evaluation `json:"evaluation"`
	Findings    []Finding  `json:"findings"`
}

var severityRank = map[string]int{
	"critical": 5,
	"high":     4,
	"medium":   3,
	"low":      2,
	"info":     1,
}

var actionRank = map[string]int{
	"pass": 0,
	"warn": 1,
	"fail": 2,
}

func BuildEvaluation(findings []Finding, policyAction func(findingID string) string) Evaluation {
	byClass := map[string]*ThreatClassSummary{}
	for _, f := range findings {
		s := byClass[f.ThreatClass]
		if s == nil {
			s = &ThreatClassSummary{ThreatClass: f.ThreatClass, PolicyAction: "pass"}
			byClass[f.ThreatClass] = s
		}
		s.FindingCount++
		if severityRank[f.Severity] > severityRank[s.HighestSeverity] {
			s.HighestSeverity = f.Severity
		}
		action := policyAction(f.ID)
		if action == "" {
			action = "warn"
		}
		if actionRank[action] > actionRank[s.PolicyAction] {
			s.PolicyAction = action
		}
	}

	rows := make([]ThreatClassSummary, 0, len(byClass))
	for _, s := range byClass {
		rows = append(rows, *s)
	}
	sort.Slice(rows, func(i, j int) bool {
		return rows[i].ThreatClass < rows[j].ThreatClass
	})

	return Evaluation{ByThreatClass: rows, TotalFindings: len(findings)}
}

func WriteJSON(path string, doc Document) error {
	data, err := json.MarshalIndent(doc, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(path, data, 0o644)
}

func WriteMarkdown(path string, doc Document) error {
	var b strings.Builder
	fmt.Fprintf(&b, "# ORCA-RUNNER Report\n\n")
	fmt.Fprintf(&b, "**Decision:** %s\n\n", strings.ToUpper(doc.Decision))
	fmt.Fprintf(&b, "**Summary:** %s\n\n", doc.Summary)
	fmt.Fprintf(&b, "| Field | Value |\n|-------|-------|\n")
	fmt.Fprintf(&b, "| Target | `%s` |\n", doc.Target)
	fmt.Fprintf(&b, "| Policy | `%s` |\n", doc.Policy)
	fmt.Fprintf(&b, "| Tool | %s %s |\n", doc.Tool, doc.ToolVersion)
	fmt.Fprintf(&b, "| Generated | %s |\n\n", doc.GeneratedAt.Format(time.RFC3339))

	if len(doc.Evaluation.ByThreatClass) > 0 {
		fmt.Fprintf(&b, "## Evaluation by threat class\n\n")
		fmt.Fprintf(&b, "Aligned with ORCA paper evaluation tables (threat-class roll-up; see report-format.md in repo docs).\n\n")
		fmt.Fprintf(&b, "| threat_class | findings | highest_severity | policy_action |\n")
		fmt.Fprintf(&b, "|--------------|----------|------------------|---------------|\n")
		for _, row := range doc.Evaluation.ByThreatClass {
			fmt.Fprintf(&b, "| %s | %d | %s | %s |\n", row.ThreatClass, row.FindingCount, row.HighestSeverity, row.PolicyAction)
		}
		fmt.Fprintf(&b, "\n**Total findings:** %d\n\n", doc.Evaluation.TotalFindings)
	}

	if len(doc.Findings) == 0 {
		fmt.Fprintf(&b, "## Findings\n\nNo findings.\n")
	} else {
		fmt.Fprintf(&b, "## Findings\n\n")
		for _, f := range doc.Findings {
			fmt.Fprintf(&b, "- **%s** (`%s`, %s) — %s\n  - %s\n  - source: `%s`\n", f.Title, f.ID, f.ThreatClass, f.Severity, f.Detail, f.Source)
		}
	}
	return os.WriteFile(path, []byte(b.String()), 0o644)
}
