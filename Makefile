.PHONY: build run shell login publish
IMGNAME=apowers313/nhai-base
VERSION=1.3.0
GITPKG=ghcr.io/$(IMGNAME)
# RUNCMD=run -p 6379:6379 -it --privileged $(IMGNAME):latest
RUNCMD=run -p 6379:6379 -p 8080:8080 -p 8888:8888 -p 8000:8000 -p 8088:8088 -it $(IMGNAME):latest

build:
	docker build . -t $(IMGNAME):latest

run:
	docker $(RUNCMD)

shell:
	docker $(RUNCMD) bash

# login requires a Personal Access Token (PAT): https://github.com/settings/tokens
login:
	docker login ghcr.io

publish:
	docker tag $(IMGNAME):latest $(GITPKG):latest
	docker tag $(IMGNAME):latest $(GITPKG):$(VERSION)
	docker push $(GITPKG):latest
	docker push $(GITPKG):$(VERSION)