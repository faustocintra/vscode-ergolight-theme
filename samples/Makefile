SHELL := /bin/sh
PACKAGE := ergolight-theme
VERSION ?= 1.0.0
SOURCES := $(wildcard *.json themes/*.json)

.PHONY: all clean package print

all: package print

package:
	vsce package --no-dependencies --out $(PACKAGE)-$(VERSION).vsix

print:
	@echo "package=$(PACKAGE) version=$(VERSION) sources=$(SOURCES)"

clean:
	$(RM) *.vsix

