package runner

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/dasmlab/orca-runner/pkg/policy"
	"github.com/dasmlab/orca-runner/pkg/report"
)

type Config struct {
	TargetPath  string
	PolicyPath  string
	ReportJSON  string
	ReportMD    string
	ToolVersion string
}

type Result struct {
	Decision string
	ExitCode int
}

func Run(cfg Config) (Result, error) {
	pol, err := policy.Load(cfg.PolicyPath)
	if err != nil {
		return Result{}, err
	}

	findings := collectFindings(cfg.TargetPath)
	decision := pol.Evaluate(findings)
	evaluation := report.BuildEvaluation(findings, pol.ActionForFinding)

	rep := report.Document{
		Schema:      "orca-report-v1",
		Tool:        "orca-runner",
		ToolVersion: cfg.ToolVersion,
		GeneratedAt: time.Now().UTC(),
		Target:      cfg.TargetPath,
		Policy:      cfg.PolicyPath,
		Decision:    decision.Label,
		Summary:     decision.Summary,
		Evaluation:  evaluation,
		Findings:    findings,
	}

	if err := report.WriteJSON(cfg.ReportJSON, rep); err != nil {
		return Result{}, err
	}
	if err := report.WriteMarkdown(cfg.ReportMD, rep); err != nil {
		return Result{}, err
	}

	return Result{Decision: decision.Label, ExitCode: decision.ExitCode}, nil
}

func collectFindings(root string) []report.Finding {
	var out []report.Finding

	_ = filepath.WalkDir(root, func(path string, d os.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return nil
		}
		lower := strings.ToLower(path)
		switch {
		case strings.HasSuffix(lower, ".yaml"), strings.HasSuffix(lower, ".yml"):
			out = append(out, scanYAML(path)...)
		case strings.HasSuffix(lower, ".py"), strings.HasSuffix(lower, ".go"), strings.HasSuffix(lower, ".sh"):
			out = append(out, scanSecrets(path)...)
			out = append(out, scanE2NodeIDs(path)...)
		case strings.HasSuffix(lower, ".json"):
			if strings.Contains(lower, "config") || strings.Contains(lower, "descriptor") {
				out = append(out, scanDescriptor(path)...)
			}
		case strings.HasSuffix(lower, ".md"):
			out = append(out, scanReadmeE2Examples(path)...)
		}
		return nil
	})

	return out
}

func scanYAML(path string) []report.Finding {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil
	}
	text := string(data)
	var findings []report.Finding
	if strings.Contains(text, "privileged: true") || strings.Contains(text, "privileged:true") {
		findings = append(findings, report.Finding{
			ID:          "k8s-privileged-pod",
			ThreatClass: "T-VM-C",
			Severity:    "high",
			Title:       "Privileged container requested",
			Detail:      "Manifest requests privileged mode",
			Source:      path,
		})
	}
	if strings.Contains(text, "hostNetwork: true") {
		findings = append(findings, report.Finding{
			ID:          "k8s-host-network",
			ThreatClass: "T-VM-C",
			Severity:    "medium",
			Title:       "hostNetwork enabled",
			Detail:      "Pod may bypass cluster network policy",
			Source:      path,
		})
	}
	return findings
}

func scanSecrets(path string) []report.Finding {
	f, err := os.Open(path)
	if err != nil {
		return nil
	}
	defer f.Close()

	var findings []report.Finding
	sc := bufio.NewScanner(f)
	lineNo := 0
	for sc.Scan() {
		lineNo++
		line := sc.Text()
		if strings.Contains(line, "AKIA") || strings.Contains(strings.ToLower(line), "password =") || strings.Contains(strings.ToLower(line), "api_key") {
			findings = append(findings, report.Finding{
				ID:          "hardcoded-secret",
				ThreatClass: "T-OPENSRC",
				Severity:    "critical",
				Title:       "Potential hardcoded secret",
				Detail:      fmt.Sprintf("suspicious credential pattern at line %d", lineNo),
				Source:      path,
			})
			break
		}
	}
	return findings
}

func scanDescriptor(path string) []report.Finding {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil
	}
	if !strings.Contains(string(data), "xapp_name") && !strings.Contains(string(data), "xAppName") {
		return []report.Finding{{
			ID:          "xapp-descriptor-incomplete",
			ThreatClass: "T-OCAPI",
			Severity:    "medium",
			Title:       "xApp descriptor may be incomplete",
			Detail:      "Expected xApp name field not found",
			Source:      path,
		}}
	}
	return nil
}

func scanE2NodeIDs(path string) []report.Finding {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil
	}
	text := string(data)
	var findings []report.Finding
	if strings.Contains(text, "gnb_001_001_000") && !strings.Contains(text, "gnbd_") {
		findings = append(findings, report.Finding{
			ID:          "legacy-e2-node-id",
			ThreatClass: "T-E2",
			Severity:    "medium",
			Title:       "Legacy E2 node ID format",
			Detail:      "Uses gnb_ prefix; srsRAN/oran-sc-ric issues suggest gnbd_ form",
			Source:      path,
		})
	}
	if strings.Contains(path, "xAppBase.py") && strings.Contains(text, "rmr_flags=0x00") {
		findings = append(findings, report.Finding{
			ID:          "rmr-flags-zero",
			ThreatClass: "T-E2",
			Severity:    "low",
			Title:       "RMR flags default 0x00",
			Detail:      "Known KPM vs RC tradeoff per oran-sc-ric issue #12",
			Source:      path,
		})
	}
	return findings
}

func scanReadmeE2Examples(path string) []report.Finding {
	if !strings.Contains(strings.ToLower(filepath.Base(path)), "readme") {
		return nil
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return nil
	}
	text := string(data)
	if strings.Contains(text, "gnb_001_001_0000019b") || strings.Contains(text, "gnb_001_001_00019b") {
		return []report.Finding{{
			ID:          "readme-e2-id-mismatch",
			ThreatClass: "T-E2",
			Severity:    "medium",
			Title:       "README E2 node ID examples may be stale",
			Detail:      "Examples use gnb_ IDs; xApp defaults use gnbd_ — causes copy-paste failures",
			Source:      path,
		}}
	}
	return nil
}
