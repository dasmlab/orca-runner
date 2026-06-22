.PHONY: build test check-unsafe check-clean tidy

BINARY=bin/orca-runner
POLICY=policies/oran-xapp-v0.yaml

build:
	mkdir -p bin
	go build -o $(BINARY) ./cmd/orca-runner

tidy:
	go mod tidy

test:
	go test ./...

check-unsafe: build
	$(BINARY) check --policy $(POLICY) examples/unsafe-xapp || test $$? -eq 2

check-clean: build
	$(BINARY) check --policy $(POLICY) examples/clean-xapp
