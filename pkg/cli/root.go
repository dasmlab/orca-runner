package cli

import (
	"flag"
	"fmt"
	"os"

	"github.com/dasmlab/orca-runner/pkg/runner"
)

const version = "0.1.0-alpha"

func Execute() error {
	if len(os.Args) < 2 {
		printUsage()
		return fmt.Errorf("missing command")
	}

	switch os.Args[1] {
	case "version", "-v", "--version":
		fmt.Println(version)
		return nil
	case "check":
		return runCheck(os.Args[2:])
	case "help", "-h", "--help":
		printUsage()
		return nil
	default:
		printUsage()
		return fmt.Errorf("unknown command: %s", os.Args[1])
	}
}

func printUsage() {
	fmt.Fprintf(os.Stderr, `orca-runner — O-RAN CI threat gate (ORCA-aligned)

Usage:
  orca-runner check [flags] <path>
  orca-runner version

Flags for check:
  --policy string     Policy YAML (default: policies/oran-xapp-v0.yaml)
  --report string     Write JSON report to path (default: orca-report.json)
  --markdown string   Write Markdown report to path (default: orca-report.md)
`)
}

func runCheck(args []string) error {
	fs := flag.NewFlagSet("check", flag.ContinueOnError)
	policyPath := fs.String("policy", "policies/oran-xapp-v0.yaml", "policy file")
	reportJSON := fs.String("report", "orca-report.json", "JSON report output")
	reportMD := fs.String("markdown", "orca-report.md", "Markdown report output")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if fs.NArg() != 1 {
		return fmt.Errorf("check requires exactly one path argument")
	}

	result, err := runner.Run(runner.Config{
		TargetPath:  fs.Arg(0),
		PolicyPath:  *policyPath,
		ReportJSON:  *reportJSON,
		ReportMD:    *reportMD,
		ToolVersion: version,
	})
	if err != nil {
		return err
	}

	fmt.Printf("orca-runner decision: %s\n", result.Decision)
	fmt.Printf("report: %s\n", *reportJSON)
	os.Exit(result.ExitCode)
	return nil
}
