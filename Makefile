VERSION=0.5.0
PATH_BUILD=build/
FILE_COMMAND=terragrunt-atlantis-config
FILE_ARCH_DARWIN=darwin_amd64
FILE_ARCH_LINUX=linux_amd64
S3_BUCKET_NAME=cloudfront-origin-homebrew-tap-transcend-io
PROFILE=transcend-prod

clean:
	rm -rf ./build
	rm -rf '$(HOME)/bin/$(FILE_COMMAND)'

build-darwin64: clean
	@$(GOPATH)/bin/goxc \
    -bc="darwin,amd64" \
    -pv=$(VERSION) \
    -d=$(PATH_BUILD) \
    -build-ldflags "-X main.VERSION=$(VERSION)"

build-linux64: clean
	@$(GOPATH)/bin/goxc \
    -bc="linux,amd64" \
    -pv=$(VERSION) \
    -d=$(PATH_BUILD) \
    -build-ldflags "-X main.VERSION=$(VERSION)"

test:
	go test -v ./...

version:
	@echo $(VERSION)

shasum-darwin64:  build-darwin64
	shasum -a256 $(PATH_BUILD)$(VERSION)/$(FILE_COMMAND)_$(VERSION)_$(FILE_ARCH_DARWIN).zip

shasum-linux64:  build-linux64
	shasum -a256 $(PATH_BUILD)$(VERSION)/$(FILE_COMMAND)_$(VERSION)_$(FILE_ARCH_LINUX).tar.gz

install:
	install -d -m 755 '$(HOME)/bin/'
	install $(PATH_BUILD)$(VERSION)/$(FILE_ARCH_DARWIN)/$(FILE_COMMAND) '$(HOME)/bin/$(FILE_COMMAND)'

publish: build
	AWS_PROFILE=$(PROFILE) aws s3 sync $(PATH_BUILD)/$(VERSION) s3://$(S3_BUCKET_NAME)/$(FILE_COMMAND)/$(VERSION)

ci_publish: build
	aws s3 sync $(PATH_BUILD)$(VERSION) s3://$(S3_BUCKET_NAME)/$(FILE_COMMAND)/$(VERSION)
