TEST?=$$(go list ./... | grep -v 'vendor')
HOSTNAME=paulfreaknbaker.com
# HOSTNAME=terraform.io
NAMESPACE=providers
# NAMESPACE=paulfreaknbaker
NAME=dockerutils
BINARY_PREFIX=terraform-provider-${NAME}
VERSION=0.0.1
GOOS?=$(shell go env GOOS)
GOARCH?=$(shell go env GOARCH)

default: install

.PHONY: build
build:
	@[ -n "${GOOS}" ] || (echo "Set GOOS"; exit 1)
	@[ -n "${GOARCH}" ] || (echo "Set GOARCH"; exit 1)
	@mkdir -p ./bin
	go build -o ./bin/${BINARY_PREFIX}_${VERSION}_${GOOS}_${GOARCH}

.PHONY: install
install:
	$(MAKE) build
	mkdir -p ${HOME}/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${GOOS}_${GOARCH}
	mv ./bin/${BINARY_PREFIX}_${VERSION}_${GOOS}_${GOARCH} ${HOME}/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${GOOS}_${GOARCH}

.PHONY: release
release:
	hash tfplugindocs || go install github.com/hashicorp/terraform-plugin-docs/cmd/tfplugindocs
	tfplugindocs
	$(MAKE) build GOOS=darwin GOARCH=amd64
	$(MAKE) build GOOS=freebsd GOARCH=386
	$(MAKE) build GOOS=freebsd GOARCH=amd64
	$(MAKE) build GOOS=freebsd GOARCH=arm
	$(MAKE) build GOOS=linux GOARCH=386
	$(MAKE) build GOOS=linux GOARCH=amd64
	$(MAKE) build GOOS=linux GOARCH=arm
	$(MAKE) build GOOS=openbsd GOARCH=386
	$(MAKE) build GOOS=openbsd GOARCH=amd64
	$(MAKE) build GOOS=solaris GOARCH=amd64
	$(MAKE) build GOOS=windows GOARCH=386
	$(MAKE) build GOOS=windows GOARCH=amd64

.PHONY: clean
clean:
	[ ! -d bin ] || rm -rfv bin
	rm -rfv test/**/{.terraform,.terraform.lock.hcl}

.PHONY: test-install
test-install:
	$(MAKE) install VERSION=0.0.0-testing

.PHONY: test
test: test-install clean
	go test -v ./...

# test: 
# 	go test -i $(TEST) || exit 1                                                   
# 	echo $(TEST) | xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4                    

# testacc: 
# 	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 120m   